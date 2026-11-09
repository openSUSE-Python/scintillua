-- Copyright 2025-2026 Mitchell. See LICENSE.
-- Typst LPeg lexer.

local lexer = lexer
local P, S, B = lpeg.P, lpeg.S, lpeg.B

local lex = lexer.new(...)

local typst_word = lexer.word_utf8 * (P('-') * lexer.word_utf8)^0
local qualified_word = typst_word * (P('.') * typst_word)^0

local statement_words = {
	'let', 'set', 'import', 'include', 'context', 'show', 'return'
}
local conditional_words = {'if', 'else'}
local loop_words = {'while', 'for'}
local operator_words = {'not', 'in', 'and', 'or'}
local constant_words = {'none', 'auto', 'true', 'false'}

-- Comments.
local line_comment = lexer.to_eol('//')
local block_comment = lexer.range('/*', '*/')
lex:add_rule('comment', lex:tag(lexer.COMMENT, block_comment + line_comment))

-- Strings.
lex:add_rule('string', lex:tag(lexer.STRING, lexer.range('"')))

-- Raw blocks and inline raw text.
lex:add_rule('raw_block', lex:tag(lexer.CODE, lexer.range('```', '```', false, false)))

local markup_start = B(S(' \t\r\n[-:/[')) + -B(1)
local markup_end = #(S(' \t\r\n-.,:;!?"\'/\\>)]}') + -lexer.any)
local function markup_region(start_delimiter, end_delimiter)
	local content = (lexer.any - P(end_delimiter) - lexer.newline - P('\\')) + P('\\') * lexer.any
	local closed_region = P(start_delimiter) * content^1 * P(end_delimiter)
	return markup_start * #closed_region * lexer.range(start_delimiter, end_delimiter, true, true) *
		markup_end
end
lex:add_rule('raw_inline', lex:tag(lexer.CODE, markup_region('`', '`')))

-- Headings.
local heading_marks = P('=') * P('=')^-5 * -P('=')
local heading = heading_marks * S(' \t')^1 * lexer.to_eol()
lex:add_rule('heading', lex:tag(lexer.HEADING, lexer.starts_line(heading, true)))

-- Bold, italic, and bold-italic text.
local bold_italic = markup_region('*_', '_*') + markup_region('_*', '*_')
lex:add_rule('bold_italic', lex:tag(lexer.BOLD, bold_italic))
lex:add_rule('bold', lex:tag(lexer.BOLD, markup_region('*', '*')))
lex:add_rule('italic', lex:tag(lexer.ITALIC, markup_region('_', '_')))

-- Links, references, and URLs.
lex:add_rule('url', lex:tag(lexer.LINK,
	lexer.alpha^1 * '://' * (lexer.any - lexer.space)^0))
lex:add_rule('reference', lex:tag(lexer.REFERENCE, P('@') * typst_word))
lex:add_rule('label', lex:tag(lexer.LABEL, P('<') * typst_word * P('>')))

-- List markers. The marker rule includes the surrounding indentation in its line check,
-- but only tags the marker and following whitespace.
local bullet_list = lexer.starts_line(P('-') * S(' \t')^1, true)
local enum_list = lexer.starts_line((P('+') + lexer.digit^1 * P('.')) * S(' \t')^1, true)
local term_text = (lexer.any - S(':\r\n\\')) + P('\\') * lexer.any
local term_list = lexer.starts_line(P('/') * S(' \t')^1 * term_text^0 * P(':'), true)
lex:add_rule('list', lex:tag(lexer.LIST, bullet_list + enum_list + term_list))

-- Hashtag expressions introduce code in markup.
local function set_word_list(target, name, words)
	local pattern = target:word_match(name)
	target:set_word_list(name, words)
	return pattern
end

local statements = set_word_list(lex, 'statements', statement_words)
local conditionals = set_word_list(lex, 'conditionals', conditional_words)
local loops = set_word_list(lex, 'loops', loop_words)
local operators = set_word_list(lex, 'word_operators', operator_words)
local constants = set_word_list(lex, 'constants', constant_words)
local hashtag_boundary = -P('-') * -lexer.word_utf8
local function hashtag_word(tag, word_pattern)
	return B('#') * lex:tag(tag, word_pattern * hashtag_boundary)
end
local binding_space = lex:tag('whitespace.typst', lexer.space^1)
local let_binding = lex:tag(lexer.PREPROCESSOR, P('#')) *
	lex:tag(lexer.KEYWORD, P('let') * hashtag_boundary) * binding_space *
	(lex:tag(lexer.DEFAULT, P('mut') * hashtag_boundary) * binding_space)^-1 *
	lex:tag(lexer.IDENTIFIER, typst_word)
local for_binding = lex:tag(lexer.PREPROCESSOR, P('#')) *
	lex:tag(lexer.KEYWORD, P('for') * hashtag_boundary) * binding_space *
	lex:tag(lexer.IDENTIFIER, typst_word)
lex:add_rule('let_binding', let_binding)
lex:add_rule('for_binding', for_binding)
lex:add_rule('hashtag', lex:tag(lexer.PREPROCESSOR, P('#')))
lex:add_rule('hashtag_statement', hashtag_word(lexer.KEYWORD, statements))
lex:add_rule('hashtag_conditional', hashtag_word(lexer.KEYWORD, conditionals))
lex:add_rule('hashtag_loop', hashtag_word(lexer.KEYWORD, loops))
lex:add_rule('hashtag_operator', hashtag_word(lexer.OPERATOR, operators))
lex:add_rule('hashtag_constant', hashtag_word(lexer.CONSTANT, constants))
lex:add_rule('hashtag_function', B('#') * lex:tag(lexer.FUNCTION,
	qualified_word * #(S(' \t')^0 * S('(['))))
lex:add_rule('hashtag_identifier', B('#') * lex:tag(lexer.IDENTIFIER, typst_word))

-- Math expressions.
local math = lexer.new('typst_math')
math:add_rule('comment', math:tag(lexer.COMMENT,
	lexer.range('/*', '*/') + lexer.to_eol('//')))
math:add_rule('string', math:tag(lexer.STRING, lexer.range('"')))

local units = P('pt') + P('mm') + P('cm') + P('in') + P('em') + P('deg') + P('rad') + P('fr') + '%'
local number = lexer.digit^1 * (P('.') * lexer.digit^1)^-1
local number_unit = B(lexer.digit) * units * -typst_word
math:add_rule('number_unit', math:tag(lexer.CONSTANT, number_unit))
math:add_rule('number', math:tag(lexer.NUMBER, number))

local math_constants = set_word_list(math, lexer.CONSTANT, constant_words)
math:add_rule('constant', math:tag(lexer.CONSTANT, math_constants))
local math_statements = set_word_list(math, 'statements', statement_words)
local math_conditionals = set_word_list(math, 'conditionals', conditional_words)
local math_loops = set_word_list(math, 'loops', loop_words)
local math_operators = set_word_list(math, 'word_operators', operator_words)
local math_boundary = -P('-') * -lexer.word_utf8
local function math_hashtag_word(tag, word_pattern)
	return B('#') * math:tag(tag, word_pattern * math_boundary)
end
math:add_rule('hashtag', math:tag(lexer.PREPROCESSOR, P('#')))
math:add_rule('hashtag_statement', math_hashtag_word(lexer.KEYWORD, math_statements))
math:add_rule('hashtag_conditional', math_hashtag_word(lexer.KEYWORD, math_conditionals))
math:add_rule('hashtag_loop', math_hashtag_word(lexer.KEYWORD, math_loops))
math:add_rule('hashtag_operator', math_hashtag_word(lexer.OPERATOR, math_operators))
math:add_rule('function', math:tag(lexer.FUNCTION,
	lexer.alpha^2 * (lexer.alnum + S('_-'))^0 * #(S(' \t')^0 * '(')))
math:add_rule('identifier', math:tag(lexer.IDENTIFIER,
	lexer.alpha^2 * (lexer.alnum + S('_-'))^0))
math:add_rule('word', math:tag(lexer.DEFAULT, typst_word))
local math_symbols = P('->') + P('<=') + P('>=') + P('!=') + P('==') +
	S('+-*/<>!=^&|:;,.()[]{}') + '→' + '←' + '↔' + '⇒' + '⇔' + '≤' + '≥' + '≠' +
	'≈' + '∈' + '∉' + '∧' + '∨' + '×' + '÷' + '±'
math:add_rule('operator', math:tag(lexer.OPERATOR, math_symbols))
math:add_rule('bold', math:tag(lexer.BOLD, markup_region('*', '*')))
math:add_rule('script', math:tag(lexer.OPERATOR, S('^_')))
local unescaped_dollar = -B('\\') * P('$')
local math_start = lex:tag(lexer.OPERATOR, unescaped_dollar)
lex:add_rule('math_delimiter', math_start)
lex:embed(math, math_start, math_start)

-- General code function calls and numeric literals.
lex:add_rule('function', lex:tag(lexer.FUNCTION,
	qualified_word * #(S(' \t')^0 * S('(['))))
lex:add_rule('number_unit', lex:tag(lexer.CONSTANT, number_unit))
lex:add_rule('number', lex:tag(lexer.NUMBER, number))
lex:add_rule('word', lex:tag(lexer.DEFAULT, typst_word))

-- Markup symbols and escapes.
local linebreak = P('\\') * (lexer.space + -lexer.any)
lex:add_rule('linebreak', lex:tag(lexer.OPERATOR, linebreak))
lex:add_rule('backslash', lex:tag(lexer.OPERATOR, P('\\\\')))
lex:add_rule('escape', lex:tag(lexer.OPERATOR, P('\\') * lexer.any))
lex:add_rule('special_symbol', lex:tag(lexer.OPERATOR,
	P('---') + P('--') + P('...') + P('-?') + P('~')))
lex:add_rule('operator', lex:tag(lexer.OPERATOR,
	P('=>') + P('==') + P('<=') + P('>=') + P('!=') + P('->') +
	S('+-*/%<>!^&|~:;,.()[]{}=$')))

-- Folding.
lex:add_fold_point(lexer.OPERATOR, '{', '}')
lex:add_fold_point(lexer.OPERATOR, '[', ']')
lex:add_fold_point(lexer.OPERATOR, '(', ')')
lex:add_fold_point(lexer.COMMENT, '/*', '*/')

local base_fold = lexer.fold
local default_lexer = lexer.new('typst_fold')
local function fold_typst(self, text, start_line, start_level)
	default_lexer._fold_points = self._fold_points
	default_lexer._case_insensitive_fold_points = self._case_insensitive_fold_points
	default_lexer._fold_by_indentation = self._fold_by_indentation
	local folds = base_fold(default_lexer, text, start_line, start_level)
	if text == '' or lexer.property_int['fold'] <= 0 then return folds end

	local headings, pos, line_num = {}, 1, 1
	local tags = self:lex(text)
	for i = 1, #tags, 2 do
		local tag, finish = tags[i], tags[i + 1]
		local token_text = text:sub(pos, finish - 1)
		if tag == lexer.HEADING then
			local marks = token_text:match('^(=+)')
			if marks then headings[line_num] = #marks end
		end
		for _ in token_text:gmatch('\n') do line_num = line_num + 1 end
		pos = finish
	end

	local FOLD_HEADER, FOLD_BLANK = lexer.FOLD_HEADER, lexer.FOLD_BLANK
	local stack, local_line = {}, 1
	for _ in (text .. '\n'):gmatch('(.-)\r?\n') do
		local line = start_line + local_line - 1
		local level = folds[line] or start_level
		local is_header = level >= FOLD_HEADER
		if is_header then level = level - FOLD_HEADER end
		local is_blank = level >= FOLD_BLANK
		if is_blank then level = level - FOLD_BLANK end

		local heading_level = headings[local_line]
		local outline_level = #stack
		if heading_level then
			while #stack > 0 and stack[#stack] >= heading_level do stack[#stack] = nil end
			outline_level = #stack
			stack[#stack + 1] = heading_level
			is_header = true
		end
		folds[line] = level + outline_level +
			(is_header and FOLD_HEADER or 0) + (is_blank and FOLD_BLANK or 0)
		local_line = local_line + 1
	end
	return folds
end
lex.fold = fold_typst

lexer.property['scintillua.comment'] = '//'

return lex
