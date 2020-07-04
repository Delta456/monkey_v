module monkey

pub struct Token {
pub mut:
	typ     string
	literal string
}

pub const (
	illegal      = 'ILLEGAL'
	eof          = 'EOF'
	// Identifiers + literals
	ident        = 'IDENT' // add, foobar, x, y, ...
	int          = 'INT' // 1343456 // Operators
	assign       = '='
	plus         = '+'
	minus        = '-'
	bang         = '!'
	asterisk     = '*'
	slash        = '/'
	lt           = '<'
	gt           = '>'
	// Delimiters
	comma        = ','
	semicolon    = ';'
	lparen       = '('
	rparen       = ')'
	lbrace       = '{'
	rbrace       = '}'
	// Keywords
	key_function = 'FUNCTION'
	key_let      = 'LET'
	key_true     = 'TRUE'
	key_false    = 'FALSE'
	key_if       = 'IF'
	key_else     = 'ELSE'
	key_return   = 'RETURN'
)

fn make_keyword() map[string]string {
	return {
		'fn': key_function
		'let': key_let
		'return': key_return
		'if': key_if
		'else': key_else
		'true': key_true
		'false': key_false
	}
}

pub const (
	keywords = make_keyword()
)

fn lookup_ident(ident string) string {
	if ident in keywords {
		return ident
	}
	return IDENT
}
