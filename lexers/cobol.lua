-- Copyright 2022-2025 Matej Cepl mcepl.att.cepl.eu. See LICENSE.

-- class CobolLexer(RegexLexer):
--     """
--     Lexer for OpenCOBOL code.
--     """
--     name = 'COBOL'
--     aliases = ['cobol']
--     filenames = ['*.cob', '*.COB', '*.cpy', '*.CPY']
--     mimetypes = ['text/x-cobol']
--     url = 'https://en.wikipedia.org/wiki/COBOL'
--     version_added = '1.6'
--
--     flags = re.IGNORECASE | re.MULTILINE
--
--     # Data Types: by PICTURE and USAGE
--     # Operators: **, *, +, -, /, <, >, <=, >=, =, <>
--     # Logical (?): NOT, AND, OR
--
--     # Reserved words:
--     # http://opencobol.add1tocobol.com/#reserved-words
--     # Intrinsics:
--     # http://opencobol.add1tocobol.com/#does-opencobol-implement-any-intrinsic-functions
--
--     tokens = {
--         'root': [
--             include('comment'),
--             include('strings'),
--             include('core'),
--             include('nums'),
--             (r'[a-z0-9]([\w\-]*[a-z0-9]+)?', Name.Variable),
--             # (r'[\s]+', Text),
--             (r'[ \t]+', Whitespace),
--         ],
--         'comment': [
--             (r'(^.{6}[*/].*\n|^.{6}|\*>.*\n)', Comment),
--         ],
--         'core': [
--             # Figurative constants
--             (r'(^|(?<=[^\w\-]))(ALL\s+)?'
--              r'((ZEROES)|(HIGH-VALUE|LOW-VALUE|QUOTE|SPACE|ZERO)(S)?)'
--              r'\s*($|(?=[^\w\-]))',
--              Name.Constant),
--
--             # Reserved words STATEMENTS and other bolds
--             (words((
--                 'ACCEPT', 'ADD', 'ALLOCATE', 'CALL', 'CANCEL', 'CLOSE', 'COMPUTE',
--                 'CONFIGURATION', 'CONTINUE', 'DATA', 'DELETE', 'DISPLAY', 'DIVIDE',
--                 'DIVISION', 'ELSE', 'END', 'END-ACCEPT',
--                 'END-ADD', 'END-CALL', 'END-COMPUTE', 'END-DELETE', 'END-DISPLAY',
--                 'END-DIVIDE', 'END-EVALUATE', 'END-IF', 'END-MULTIPLY', 'END-OF-PAGE',
--                 'END-PERFORM', 'END-READ', 'END-RETURN', 'END-REWRITE', 'END-SEARCH',
--                 'END-START', 'END-STRING', 'END-SUBTRACT', 'END-UNSTRING', 'END-WRITE',
--                 'ENVIRONMENT', 'EVALUATE', 'EXIT', 'FD', 'FILE', 'FILE-CONTROL', 'FOREVER',
--                 'FREE', 'GENERATE', 'GO', 'GOBACK', 'IDENTIFICATION', 'IF', 'INITIALIZE',
--                 'INITIATE', 'INPUT-OUTPUT', 'INSPECT', 'INVOKE', 'I-O-CONTROL', 'LINKAGE',
--                 'LOCAL-STORAGE', 'MERGE', 'MOVE', 'MULTIPLY', 'OPEN', 'PERFORM',
--                 'PROCEDURE', 'PROGRAM-ID', 'RAISE', 'READ', 'RELEASE', 'RESUME',
--                 'RETURN', 'REWRITE', 'SCREEN', 'SD', 'SEARCH', 'SECTION', 'SET',
--                 'SORT', 'START', 'STOP', 'STRING', 'SUBTRACT', 'SUPPRESS',
--                 'TERMINATE', 'THEN', 'UNLOCK', 'UNSTRING', 'USE', 'VALIDATE',
--                 'WORKING-STORAGE', 'WRITE'), prefix=r'(^|(?<=[^\w\-]))',
--                 suffix=r'\s*($|(?=[^\w\-]))'),
--              Keyword.Reserved),
--
--             # Reserved words
--             (words((
--                 'ACCESS', 'ADDRESS', 'ADVANCING', 'AFTER', 'ALL',
--                 'ALPHABET', 'ALPHABETIC', 'ALPHABETIC-LOWER', 'ALPHABETIC-UPPER',
--                 'ALPHANUMERIC', 'ALPHANUMERIC-EDITED', 'ALSO', 'ALTER', 'ALTERNATE'
--                 'ANY', 'ARE', 'AREA', 'AREAS', 'ARGUMENT-NUMBER', 'ARGUMENT-VALUE', 'AS',
--                 'ASCENDING', 'ASSIGN', 'AT', 'AUTO', 'AUTO-SKIP', 'AUTOMATIC',
--                 'AUTOTERMINATE', 'BACKGROUND-COLOR', 'BASED', 'BEEP', 'BEFORE', 'BELL',
--                 'BLANK', 'BLINK', 'BLOCK', 'BOTTOM', 'BY', 'BYTE-LENGTH', 'CHAINING',
--                 'CHARACTER', 'CHARACTERS', 'CLASS', 'CODE', 'CODE-SET', 'COL',
--                 'COLLATING', 'COLS', 'COLUMN', 'COLUMNS', 'COMMA', 'COMMAND-LINE',
--                 'COMMIT', 'COMMON', 'CONSTANT', 'CONTAINS', 'CONTENT', 'CONTROL',
--                 'CONTROLS', 'CONVERTING', 'COPY', 'CORR', 'CORRESPONDING', 'COUNT', 'CRT',
--                 'CURRENCY', 'CURSOR', 'CYCLE', 'DATE', 'DAY', 'DAY-OF-WEEK', 'DE',
--                 'DEBUGGING', 'DECIMAL-POINT', 'DECLARATIVES', 'DEFAULT', 'DELIMITED',
--                 'DELIMITER', 'DEPENDING', 'DESCENDING', 'DETAIL', 'DISK',
--                 'DOWN', 'DUPLICATES', 'DYNAMIC', 'EBCDIC',
--                 'ENTRY', 'ENVIRONMENT-NAME', 'ENVIRONMENT-VALUE', 'EOL', 'EOP',
--                 'EOS', 'ERASE', 'ERROR', 'ESCAPE', 'EXCEPTION',
--                 'EXCLUSIVE', 'EXTEND', 'EXTERNAL', 'FILE-ID', 'FILLER', 'FINAL',
--                 'FIRST', 'FIXED', 'FLOAT-LONG', 'FLOAT-SHORT',
--                 'FOOTING', 'FOR', 'FOREGROUND-COLOR', 'FORMAT', 'FROM', 'FULL',
--                 'FUNCTION', 'FUNCTION-ID', 'GIVING', 'GLOBAL', 'GROUP',
--                 'HEADING', 'HIGHLIGHT', 'I-O', 'ID',
--                 'IGNORE', 'IGNORING', 'IN', 'INDEX', 'INDEXED', 'INDICATE',
--                 'INITIAL', 'INITIALIZED', 'INPUT', 'INTO', 'INTRINSIC', 'INVALID',
--                 'IS', 'JUST', 'JUSTIFIED', 'KEY', 'LABEL',
--                 'LAST', 'LEADING', 'LEFT', 'LENGTH', 'LIMIT', 'LIMITS', 'LINAGE',
--                 'LINAGE-COUNTER', 'LINE', 'LINES', 'LOCALE', 'LOCK',
--                 'LOWLIGHT', 'MANUAL', 'MEMORY', 'MINUS', 'MODE', 'MULTIPLE',
--                 'NATIONAL', 'NATIONAL-EDITED', 'NATIVE', 'NEGATIVE', 'NEXT', 'NO',
--                 'NULL', 'NULLS', 'NUMBER', 'NUMBERS', 'NUMERIC', 'NUMERIC-EDITED',
--                 'OBJECT-COMPUTER', 'OCCURS', 'OF', 'OFF', 'OMITTED', 'ON', 'ONLY',
--                 'OPTIONAL', 'ORDER', 'ORGANIZATION', 'OTHER', 'OUTPUT', 'OVERFLOW',
--                 'OVERLINE', 'PACKED-DECIMAL', 'PADDING', 'PAGE', 'PARAGRAPH',
--                 'PLUS', 'POINTER', 'POSITION', 'POSITIVE', 'PRESENT', 'PREVIOUS',
--                 'PRINTER', 'PRINTING', 'PROCEDURE-POINTER', 'PROCEDURES',
--                 'PROCEED', 'PROGRAM', 'PROGRAM-POINTER', 'PROMPT', 'QUOTE',
--                 'QUOTES', 'RANDOM', 'RD', 'RECORD', 'RECORDING', 'RECORDS', 'RECURSIVE',
--                 'REDEFINES', 'REEL', 'REFERENCE', 'RELATIVE', 'REMAINDER', 'REMOVAL',
--                 'RENAMES', 'REPLACING', 'REPORT', 'REPORTING', 'REPORTS', 'REPOSITORY',
--                 'REQUIRED', 'RESERVE', 'RETURNING', 'REVERSE-VIDEO', 'REWIND',
--                 'RIGHT', 'ROLLBACK', 'ROUNDED', 'RUN', 'SAME', 'SCROLL',
--                 'SECURE', 'SEGMENT-LIMIT', 'SELECT', 'SENTENCE', 'SEPARATE',
--                 'SEQUENCE', 'SEQUENTIAL', 'SHARING', 'SIGN', 'SIGNED', 'SIGNED-INT',
--                 'SIGNED-LONG', 'SIGNED-SHORT', 'SIZE', 'SORT-MERGE', 'SOURCE',
--                 'SOURCE-COMPUTER', 'SPECIAL-NAMES', 'STANDARD',
--                 'STANDARD-1', 'STANDARD-2', 'STATUS', 'SUBKEY', 'SUM',
--                 'SYMBOLIC', 'SYNC', 'SYNCHRONIZED', 'TALLYING', 'TAPE',
--                 'TEST', 'THROUGH', 'THRU', 'TIME', 'TIMES', 'TO', 'TOP', 'TRAILING',
--                 'TRANSFORM', 'TYPE', 'UNDERLINE', 'UNIT', 'UNSIGNED',
--                 'UNSIGNED-INT', 'UNSIGNED-LONG', 'UNSIGNED-SHORT', 'UNTIL', 'UP',
--                 'UPDATE', 'UPON', 'USAGE', 'USING', 'VALUE', 'VALUES', 'VARYING',
--                 'WAIT', 'WHEN', 'WITH', 'WORDS', 'YYYYDDD', 'YYYYMMDD'),
--                 prefix=r'(^|(?<=[^\w\-]))', suffix=r'\s*($|(?=[^\w\-]))'),
--              Keyword.Pseudo),
--
--             # inactive reserved words
--             (words((
--                 'ACTIVE-CLASS', 'ALIGNED', 'ANYCASE', 'ARITHMETIC', 'ATTRIBUTE',
--                 'B-AND', 'B-NOT', 'B-OR', 'B-XOR', 'BIT', 'BOOLEAN', 'CD', 'CENTER',
--                 'CF', 'CH', 'CHAIN', 'CLASS-ID', 'CLASSIFICATION', 'COMMUNICATION',
--                 'CONDITION', 'DATA-POINTER', 'DESTINATION', 'DISABLE', 'EC', 'EGI',
--                 'EMI', 'ENABLE', 'END-RECEIVE', 'ENTRY-CONVENTION', 'EO', 'ESI',
--                 'EXCEPTION-OBJECT', 'EXPANDS', 'FACTORY', 'FLOAT-BINARY-16',
--                 'FLOAT-BINARY-34', 'FLOAT-BINARY-7', 'FLOAT-DECIMAL-16',
--                 'FLOAT-DECIMAL-34', 'FLOAT-EXTENDED', 'FORMAT', 'FUNCTION-POINTER',
--                 'GET', 'GROUP-USAGE', 'IMPLEMENTS', 'INFINITY', 'INHERITS',
--                 'INTERFACE', 'INTERFACE-ID', 'INVOKE', 'LC_ALL', 'LC_COLLATE',
--                 'LC_CTYPE', 'LC_MESSAGES', 'LC_MONETARY', 'LC_NUMERIC', 'LC_TIME',
--                 'LINE-COUNTER', 'MESSAGE', 'METHOD', 'METHOD-ID', 'NESTED', 'NONE',
--                 'NORMAL', 'OBJECT', 'OBJECT-REFERENCE', 'OPTIONS', 'OVERRIDE',
--                 'PAGE-COUNTER', 'PF', 'PH', 'PROPERTY', 'PROTOTYPE', 'PURGE',
--                 'QUEUE', 'RAISE', 'RAISING', 'RECEIVE', 'RELATION', 'REPLACE',
--                 'REPRESENTS-NOT-A-NUMBER', 'RESET', 'RESUME', 'RETRY', 'RF', 'RH',
--                 'SECONDS', 'SEGMENT', 'SELF', 'SEND', 'SOURCES', 'STATEMENT',
--                 'STEP', 'STRONG', 'SUB-QUEUE-1', 'SUB-QUEUE-2', 'SUB-QUEUE-3',
--                 'SUPER', 'SYMBOL', 'SYSTEM-DEFAULT', 'TABLE', 'TERMINAL', 'TEXT',
--                 'TYPEDEF', 'UCS-4', 'UNIVERSAL', 'USER-DEFAULT', 'UTF-16', 'UTF-8',
--                 'VAL-STATUS', 'VALID', 'VALIDATE', 'VALIDATE-STATUS'),
--                    prefix=r'(^|(?<=[^\w\-]))', suffix=r'\s*($|(?=[^\w\-]))'),
--              Error),
--
--             # Data Types
--             (r'(^|(?<=[^\w\-]))'
--              r'(PIC\s+.+?(?=(\s|\.\s))|PICTURE\s+.+?(?=(\s|\.\s))|'
--              r'(COMPUTATIONAL)(-[1-5X])?|(COMP)(-[1-5X])?|'
--              r'BINARY-C-LONG|'
--              r'BINARY-CHAR|BINARY-DOUBLE|BINARY-LONG|BINARY-SHORT|'
--              r'BINARY)\s*($|(?=[^\w\-]))', Keyword.Type),
--
--             # Operators
--             (r'(\*\*|\*|\+|-|/|<=|>=|<|>|==|/=|=)', Operator),
--
--             # (r'(::)', Keyword.Declaration),
--
--             (r'([(),;:&%.])', Punctuation),
--
--             # Intrinsics
--             (r'(^|(?<=[^\w\-]))(ABS|ACOS|ANNUITY|ASIN|ATAN|BYTE-LENGTH|'
--              r'CHAR|COMBINED-DATETIME|CONCATENATE|COS|CURRENT-DATE|'
--              r'DATE-OF-INTEGER|DATE-TO-YYYYMMDD|DAY-OF-INTEGER|DAY-TO-YYYYDDD|'
--              r'EXCEPTION-(?:FILE|LOCATION|STATEMENT|STATUS)|EXP10|EXP|E|'
--              r'FACTORIAL|FRACTION-PART|INTEGER-OF-(?:DATE|DAY|PART)|INTEGER|'
--              r'LENGTH|LOCALE-(?:DATE|TIME(?:-FROM-SECONDS)?)|LOG(?:10)?|'
--              r'LOWER-CASE|MAX|MEAN|MEDIAN|MIDRANGE|MIN|MOD|NUMVAL(?:-C)?|'
--              r'ORD(?:-MAX|-MIN)?|PI|PRESENT-VALUE|RANDOM|RANGE|REM|REVERSE|'
--              r'SECONDS-FROM-FORMATTED-TIME|SECONDS-PAST-MIDNIGHT|SIGN|SIN|SQRT|'
--              r'STANDARD-DEVIATION|STORED-CHAR-LENGTH|SUBSTITUTE(?:-CASE)?|'
--              r'SUM|TAN|TEST-DATE-YYYYMMDD|TEST-DAY-YYYYDDD|TRIM|'
--              r'UPPER-CASE|VARIANCE|WHEN-COMPILED|YEAR-TO-YYYY)\s*'
--              r'($|(?=[^\w\-]))', Name.Function),
--
--             # Booleans
--             (r'(^|(?<=[^\w\-]))(true|false)\s*($|(?=[^\w\-]))', Name.Builtin),
--             # Comparing Operators
--             (r'(^|(?<=[^\w\-]))(equal|equals|ne|lt|le|gt|ge|'
--              r'greater|less|than|not|and|or)\s*($|(?=[^\w\-]))', Operator.Word),
--         ],
--
--         # \"[^\"\n]*\"|\'[^\'\n]*\'
--         'strings': [
--             # apparently strings can be delimited by EOL if they are continued
--             # in the next line
--             (r'"[^"\n]*("|\n)', String.Double),
--             (r"'[^'\n]*('|\n)", String.Single),
--         ],
--
--         'nums': [
--             (r'\d+(\s*|\.$|$)', Number.Integer),
--             (r'[+-]?\d*\.\d+(E[-+]?\d+)?', Number.Float),
--             (r'[+-]?\d+\.\d*(E[-+]?\d+)?', Number.Float),
--         ],
--     }
--
--
-- class CobolFreeformatLexer(CobolLexer):
--     """
--     Lexer for Free format OpenCOBOL code.
--     """
--     name = 'COBOLFree'
--     aliases = ['cobolfree']
--     filenames = ['*.cbl', '*.CBL']
--     mimetypes = []
--     url = 'https://opencobol.add1tocobol.com'
--     version_added = '1.6'
--
--     flags = re.IGNORECASE | re.MULTILINE
--
--     tokens = {
--         'comment': [
--             (r'(\*>.*\n|^\w*\*.*$)', Comment),
--         ],
--     }

local lexer = lexer
local P, S = lpeg.P, lpeg.S

local lex = lexer.new(...)

-- Keywords.
lex:add_rule('keyword', lex:tag(lexer.KEYWORD, lex:word_match(lexer.KEYWORD)))

-- Identifiers.
lex:add_rule('identifier', lex:tag(lexer.IDENTIFIER, lexer.word))

-- Strings.
local sq_str = lexer.range("'")
local dq_str = lexer.range('"')
lex:add_rule('string', lex:tag(lexer.STRING, sq_str + dq_str))

-- Comments.
lex:add_rule('comment', lex:tag(lexer.COMMENT, lexer.to_eol('#')))

-- Numbers.
lex:add_rule('number', lex:tag(lexer.NUMBER, lexer.number))

-- Operators.
lex:add_rule('operator', lex:tag(lexer.OPERATOR, S('+-*/%^=<>,.{}[]()')))

-- Fold points.
lex:add_fold_point(lexer.KEYWORD, 'start', 'end')
lex:add_fold_point(lexer.OPERATOR, '{', '}')

-- Word lists.
lex:set_word_list(lexer.KEYWORD, {
  'keyword1', 'keyword2', 'keyword3'
})

lexer.property['scintillua.comment'] = '#'

return lex
