module main

struct Token  {
 mut:
	typ    string
	literal string
}

const (
	ILLEGAL = "ILLEGAL"
	EOF     = "EOF"
	// Identifiers + literals
	IDENT = "IDENT" // add, foobar, x, y, ...
	INT   = "INT"   // 1343456
	// Operators
	ASSIGN = "="
	PLUS   = "+"
	// Delimiters
	COMMA     = ","
	SEMICOLON = ";"
	LPAREN    = "("
	RPAREN    = ")"
	LBRACE    = "{"
	RBRACE    = "}"
	// Keywords
	FUNCTION = "FUNCTION"
	LET      = "LET"
	TRUE     = "TRUE"
	FALSE    = "FALSE"
	IF       = "IF"
	ELSE     = "ELSE"
	RETURN   = "RETURN"
)

fn make_keyword() map[string]string { 
	return {
	"fn":FUNCTION, 
	"let":LET, 
	"return": RETURN, 
	"if": IF,
    "else":  ELSE,
	"true":  TRUE,
	"false":  FALSE
	}
}

const (
	keywords = make_keyword()
)
  
/* TODO: Remove when it's implemented
pub fn LookupIdent(ident string) TokenType {
	if tok, ok := keywords[ident]; ok {
		return tok
	}
	return IDENT
}
*/
