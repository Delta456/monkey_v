module token

//pub type TokenType string

pub struct Token {
pub mut:
	typ string
	literal string
}

pub const (
	illegal = 'ILLEGAL'	
	eof = 'EOF'

	// Identifiers + lierals
	ident = 'ident'
	int = 'INT'

	// Operators
	assign = '='
	plus = '+'

	// Delimiters
	l_brace = '{'
	r_brace = '}'
	l_paren = '('
	r_paren = ')'
    semicolon = ';'
	colon = ','
    
	// Keywords
	function = 'fn'
	let = 'let'

	keywords = {'fn': function, 'let': let}
)

pub fn lookup_ident(ident_ string) string {
	if ident_ in keywords {
		return ident_
	}
	return ident
} 