--[[ Textadept Org module -- Org agenda LPeg lexer
Copyright (c) 2012 joten
Copyright (c) 2025 Matěj Cepl (@mcepl everywhere)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
--]]

local lexer = lexer
local word_match = lexer.word_match
local P, R, S, V = lpeg.P, lpeg.R, lpeg.S, lpeg.V
lpeg.locale(lpeg)

local lex = lexer.new(...)

--[[Overview. Used examples.
* Heading 1-5 (8)
	TODO special color, bold
	DONE special color, bold
	[#priority]
	:tag: bold
<date> / [date] like heading 3, underlined
	keywords: CLOSED: DEADLINE: SCHEDULED: like heading 3, not underlined
| table | like heading 1
[[link][description] ]
formatting:
	*bold*
	/italic/
	_underline_
	+strike+
--]]

-- Font formats.
lex:add_rule('bold', lex:tag('BOLD',      '*' * lexer.word^1 * '*'))
lex:add_rule('italic', lex:tag('ITALIC',    '/' * lexer.word^1 * '/'))
lex:add_rule('underline', lex:tag('UNDERLINE', '_' * lexer.alnum^1 * '_'))

-- ToDos.
lex:add_rule('todo', lex:tag('TODO', lex:word_match('TODO')))
lex:set_word_list('TODO', {'TODO', 'DELEGATED', 'WAITING'})
lex:add_rule('done', lex:tag('DONE', lex:word_match('DONE')))
lex:set_word_list('DONE', {'DONE'})
lex:add_rule('wontfix', lex:tag('WONTFIX', lex:word_match('WONTFIX')))
lex:set_word_list('WONTFIX', {'WONTFIX', 'INVALID'})
local agenda_tags = P('TODO') + 'DONE' + 'WONTFIX'

-- XXX I don’t care about priority, if anybody cares, send me a patch
-- Also, I don’t think that the TAG is the right name, just use a custom tag
-- local priority = lex:tag('PRIORITY', '[#' * S('ABC') * ']')
-- local tags = lex:tag('TAG', ':' * (lexer.word + lexer.punct)^1 * lexer.newline)

-- XXX not sure what it is good for
-- Keywords.
-- lex:add_rule('keyword', lex:tag(lexer.KEYWORD, lex:word_match(lexer.KEYWORD)))
-- lex:set_word_list(lexer.KEYWORD, {'SCHEDULED', 'DEADLINE', 'CLOSED'})

-- DateTime.
local DD =   lexer.digit * lexer.digit
local date = DD * DD * '-' * DD * '-' * DD
lex:set_word_list('wday', {
	'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So',
	'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
	'Po', 'Út', 'St', 'Čt', 'Pá', 'So', 'Ne'
})
lex:set_word_list('weekday', {
	'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag',
	'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
	'Pondělí', 'Úterý', 'Středa', 'Čtvrtek', 'Pátek', 'Sobota', 'Neděle'
})
lex:set_word_list('month', {
	'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
	'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December',
	'Leden', 'Únor', 'Březen', 'Duben', 'Květen', 'Červen', 'Červenec', 'Srpen', 'Září', 'Říjen', 'Listopad', 'Prosince'
})
local time_range = (' ' * DD * ':' * DD)^0 * ('-' * DD * ':' * DD)^0
local repeater =   (' +' * lexer.integer * S('dwmy'))^0
local alarm =      (' -' * lexer.integer * S('dwmy'))^0
local pattern_datetime1 = S('<[')^-1 * 'date' * 'wday' * time_range * repeater * alarm * S('>]')^-1
local pattern_datetime2 = lexer.starts_line('weekday') * lexer.space^1 * DD * '. ' * 'month' * lexer.space^1 * DD * DD
local datetime =   pattern_datetime1 + pattern_datetime2

lex:add_rule('current_date', lex:tag('CURRENT_DATE', lexer.starts_line(lex:word_match('weekday')) * lexer.space^1 * DD * '. ' * lex:word_match('month') * lexer.space^1 * DD * DD * '|'))
lex:add_rule('time', lex:tag(lexer.CLASS, DD * ':' * DD))
lex:add_rule('week', lex:tag('UNDERLINE', lexer.starts_line('KW ' * DD * lexer.space^25) + lexer.starts_line('Wk ' * DD * lexer.space^25)))
lex:add_rule('datetime', lex:tag(lexer.NUMBER, lex:word_match('datetime')))

-- Heading patterns.
local pattern_priority = '[#' * S('ABC') * ']'
local pattern_tags = ':' * (lexer.word + lexer.punct)^1 * lexer.newline
local pattern_h1 = lexer.starts_line('* ')        -- Heading1.
local pattern_h2 = lexer.starts_line('** ')       -- Heading2.
local pattern_h3 = lexer.starts_line('*** ')      -- Heading3.
local pattern_h4 = lexer.starts_line('**** ')     -- Heading4.
local pattern_h5 = lexer.starts_line('***** ')    -- Heading5.

-- Heading lex:tag parts.
local part_h1 = lex:tag(lexer.CLASS,        (lexer.nonnewline - S('<[') - (':' * lexer.word))^0) * datetime^0 * lex:tag(lexer.CLASS,        (lexer.nonnewline - (':' * lexer.word))^0)
local part_h2 = lex:tag(lexer.STRING,       (lexer.nonnewline - S('<[') - (':' * lexer.word))^0) * datetime^0 * lex:tag(lexer.STRING,       (lexer.nonnewline - (':' * lexer.word))^0)
local part_h3 = lex:tag(lexer.FUNCTION,     (lexer.nonnewline - S('<[') - (':' * lexer.word))^0) * datetime^0 * lex:tag(lexer.FUNCTION,     (lexer.nonnewline - (':' * lexer.word))^0)
local part_h4 = lex:tag(lexer.PREPROCESSOR, (lexer.nonnewline - S('<[') - (':' * lexer.word))^0) * datetime^0 * lex:tag(lexer.PREPROCESSOR, (lexer.nonnewline - (':' * lexer.word))^0)
local part_h5 = lex:tag(lexer.CONSTANT,     (lexer.nonnewline - S('<[') - (':' * lexer.word))^0) * datetime^0 * lex:tag(lexer.CONSTANT,     (lexer.nonnewline - (':' * lexer.word))^0)
-- Headings.
local h1 = lex:tag(lexer.CLASS, pattern_h1) *        (agenda_tags * lpeg.space)^0 * (lex:tag('PRIORITY1', pattern_priority) * lpeg.space)^0 * part_h1 * (lex:tag('TAG1', pattern_tags))^0
local h2 = lex:tag(lexer.STRING, pattern_h2) *       (agenda_tags * lpeg.space)^0 * (lex:tag('PRIORITY2', pattern_priority) * lpeg.space)^0 * part_h2 * (lex:tag('TAG2', pattern_tags))^0
local h3 = lex:tag(lexer.FUNCTION, pattern_h3) *     (agenda_tags * lpeg.space)^0 * (lex:tag('PRIORITY3', pattern_priority) * lpeg.space)^0 * part_h3 * (lex:tag('TAG3', pattern_tags))^0
local h4 = lex:tag(lexer.PREPROCESSOR, pattern_h4) * (agenda_tags * lpeg.space)^0 * (lex:tag('PRIORITY4', pattern_priority) * lpeg.space)^0 * part_h4 * (lex:tag('TAG4', pattern_tags))^0
local h5 = lex:tag(lexer.CONSTANT, pattern_h5) *     (agenda_tags * lpeg.space)^0 * (lex:tag('PRIORITY5', pattern_priority) * lpeg.space)^0 * part_h5 * (lex:tag('TAG5', pattern_tags))^0

-- Links.
local orgmode_link = '[[' * (lexer.nonnewline - ' ' - ']')^1 * ']' * ('[' * (lexer.nonnewline - ']')^1 * ']')^0 * ']'
lex:add_rule('link', lex:tag(lexer.FUNCTION, orgmode_link))

-- Strings.
-- local sq_str = P('L')^-1 * lexer.range("'")
local dq_str = P('L')^-1 * lexer.range('"')
-- lex:add_rule('string', lex:tag(lexer.STRING, sq_str + dq_str))
lex:add_rule('string', lex:tag(lexer.STRING, dq_str))

-- Comments.
lex:add_rule('comment', lex:tag(lexer.COMMENT,
	lexer.starts_line(lexer.to_eol('# ')) +
	lexer.range(lexer.starts_line('#+BEGIN_COMMENT'),
		lexer.starts_line('#+END_COMMENT'))))

lexer.property['scintillua.comment'] = '#'

return lex
