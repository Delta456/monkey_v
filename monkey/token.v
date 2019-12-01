module monkey

pub struct Token  {
 pub:
 mut:
	typ    string
	literal string
}

pub const (
	ILLEGAL = "ILLEGAL"
	EOF     = "EOF"
	// Identifiers + literals
	IDENT = "IDENT" // add, foobar, x, y, ...
	INT   = "INT"   // 1343456
	// Operators
	ASSIGN = "="
	PLUS   = "+"
	MINUS = "-"
    BANG = "!"
    ASTERISK = "*"
    SLASH = "/"
    LT = "<"
    GT = ">"
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

pub const (
	keywords = make_keyword()
)
  
fn lookup_ident(ident string) string {
	if ident in keywords {
		return ident
	}
	return IDENT
}

