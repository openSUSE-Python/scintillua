-- Copyright 2024 Mitchell. See LICENSE.
-- Typst LPeg lexer.

local lexer = lexer
local word_match = lexer.word_match
local P, S = lpeg.P, lpeg.S

local lex = lexer.new(...)

-- Comments
local line_comment = '//' * lexer.non_newline^0
local block_comment = lexer.range('/*', '*/')
lex:add_rule('comment', lex:tag(lexer.COMMENT, line_comment + block_comment))

-- Strings
local dq_str = lexer.range('"')
lex:add_rule('string', lex:tag(lexer.STRING, dq_str))

-- Numbers
local units = P('pt') + 'mm' + 'cm' + 'in' + 'em' + 'deg' + 'rad' + 'fr' + '%'
lex:add_rule('number', lex:tag(lexer.NUMBER, lexer.number * units^-1))

-- Headings
-- Matches 1 to 6 '=' characters at the beginning of a line.
local function h(n)
  return lex:tag('heading' .. n, lexer.starts_line(P('='):rep(n) * P(' ')))
end
lex:add_rule('headings', h(6) + h(5) + h(4) + h(3) + h(2) + h(1))

-- Markup
lex:add_rule('bold', lex:tag('bold', lexer.range('*', '*', true, true)))
lex:add_rule('italic', lex:tag('italic', lexer.range('_', '_', true, true)))
lex:add_rule('url', lex:tag('url', (P('http') + 'https' ) * '://' * (1 - lexer.space)^1))
lex:add_rule('raw_inline', lex:tag('raw', lexer.range('`', '`')))
lex:add_rule('raw_block', lex:tag('raw_block', lexer.range('```', '```', false, false)))
lex:add_rule('linebreak', lex:tag('special_symbol', P('\\\\')))
lex:add_rule('special_whitespace', lex:tag('special_symbol', S('~') + P('-?')))
lex:add_rule('special_symbols', lex:tag('special_symbol', P('---') + '--' + '...'))
lex:add_rule('reference', lex:tag('label', P('@') * (lexer.word + '-')^1))
lex:add_rule('label', lex:tag('label', lexer.range('<', '>', true, true)))

-- Lists
local bullet_list = lexer.starts_line(S(' \t')^0 * '-' * ' ')
local enum_list = lexer.starts_line(S(' \t')^0 * (P('+') + lexer.digit^1 * '.') * ' ')
local term_list = lexer.starts_line(S(' \t')^0 * '/' * ' ') * lexer.non_newline^0 * P(':')
lex:add_rule('list', lex:tag('list', bullet_list + enum_list + term_list))

-- Keywords and Constants
lex:set_word_list(statements, {
 'let', 'set', 'import', 'include', 'context', 'show'
})
lex:set_word_list(conditionals, {
 'if', 'else',
})
lex:set_word_list(repeats, {
 'while', 'for',
})
lex:set_word_list(other_keywords, {
 'not', 'in', 'and', 'or', 'return',
})
lex:set_word_list(constants, {
 'none', 'auto', 'true', 'false',
})
local all_keywords = statements + conditionals + repeats + other_keywords + constants

-- Hashtag expressions (code entry points in markup)
local hashtag_prefix = P('#') * (1 - S(' \t\r\n('))^0
lex:add_rule('hashtag_statement', lex:tag(lexer.KEYWORD, hashtag_prefix * statements))
lex:add_rule('hashtag_conditional', lex:tag(lexer.KEYWORD, hashtag_prefix * conditionals))
lex:add_rule('hashtag_repeat', lex:tag(lexer.KEYWORD, hashtag_prefix * repeats))
lex:add_rule('hashtag_keyword', lex:tag(lexer.KEYWORD, hashtag_prefix * other_keywords))
lex:add_rule('hashtag_constant', lex:tag(lexer.CONSTANT, hashtag_prefix * constants))
lex:add_rule('hashtag_function', lex:tag(lexer.FUNCTION, P('#') * lexer.word * lexer.space^0 * S('([')))
lex:add_rule('hashtag_identifier', lex:tag(lexer.IDENTIFIER, P('#') * lexer.word))

-- Code context keywords and identifiers
lex:add_rule('statement', lex:tag(lexer.KEYWORD, lex:word_match(statements)))
lex:add_rule('conditional', lex:tag(lexer.KEYWORD, lex:word_match(conditionals)))
lex:add_rule('repeat', lex:tag(lexer.KEYWORD, lex:word_match(repeats)))
lex:add_rule('keyword', lex:tag(lexer.KEYWORD, lex:word_match(other_keywords)))
lex:add_rule('constant', lex:tag(lexer.CONSTANT, lex:word_match(constants)))
lex:add_rule('function', lex:tag(lexer.FUNCTION, lexer.word * lexer.space^0 * S('([')))
lex:add_rule('identifier', lex:tag(lexer.IDENTIFIER, lexer.word))

-- Operators and Delimiters
lex:add_rule('math_delimiter', lex:tag('math', P('$')))
lex:add_rule('operator', lex:tag(lexer.OPERATOR, S('+-/*%<>!^&|~:;,.()[]{}') + P('=>') + P('=')))

---
## Styling

-- Standard styles
lex:add_style(lexer.KEYWORD, {fore = lexer.colors.purple})
lex:add_style(lexer.CONSTANT, {fore = lexer.colors.cyan})
lex:add_style('list', {fore = lexer.colors.purple})

-- Headings (progressively larger font size)
local font_size = tonumber(lexer.property_expanded['style.default']:match('size:(%d+)')) or 10
for i = 1, 6 do
  lex:add_style('heading' .. i, {fore = lexer.colors.red, size = (font_size + (6 - i)), bold = true})
end

-- Markup styles
lex:add_style('bold', {bold = true})
lex:add_style('italic', {italic = true})
lex:add_style('url', {fore = lexer.colors.blue, underline = true})
lex:add_style('raw', {fore = lexer.colors.gray})
lex:add_style('raw_block', {back = lexer.colors.light_gray})
lex:add_style('special_symbol', {fore = lexer.colors.orange})
lex:add_style('label', {fore = lexer.colors.green, back = lexer.colors.light_gray})
lex:add_style('math', {fore = lexer.colors.green})

---
## Folding

lex:add_fold_point(lexer.OPERATOR, '{', '}')
lex:add_fold_point(lexer.OPERATOR, '[', ']')
lex:add_fold_point(lexer.OPERATOR, '(', ')')
lex:add_fold_point(lexer.COMMENT, '/*', '*/')
lex:add_fold_point(lexer.COMMENT, '//', lexer.fold_line_comments('//'))

return lex
