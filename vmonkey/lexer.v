module vmonkey

struct Lexer {
 mut:
	input   string
	pos     int  // current position in input (points to current char)
	readpos int  // current read position in input (after current char)
	chr     byte // current char under examination
}

fn new_lexer(input string) &Lexer {
	mut l := &Lexer{input: input}
	l.readchar()
	return l
}

fn (l mut Lexer) readchar() {
	if l.readpos >= l.input.len {
		l.chr = 0
	} else {
		l.chr = l.input[l.readpos]
		l.pos = l.readpos
		l.readpos++
	}
}

fn new_token(tokentype string, ch byte) Token {
	return Token{typ: tokentype, literal: tos2(ch)}
}

fn (l mut Lexer) next_token() Token {
	mut tok := Token{}
	l.skip_whitespace()
	match l.chr {
	`=` { tok = new_token(ASSIGN, l.chr) }
	`+` { tok = new_token(PLUS, l.chr) }
	`;` { tok = new_token(SEMICOLON, l.chr) }
	`{` { tok = new_token(LBRACE, l.chr) }
	`}` { tok = new_token(RBRACE, l.chr) }
	 0 {
		tok.literal = ""
		tok.typ = EOF
	   }
	else {
		if is_letter(l.chr) {
			tok.literal = l.read_identifier()
		//	tok.Type = token.lookup_ident(tok.Literal)
			return tok
		} else {
			tok = new_token(ILLEGAL, l.chr)
		}
     }
	}
	l.readchar()
	return tok
}

fn (l mut Lexer) read_identifier() string {

	position := l.pos

	for is_letter(l.chr) {
		l.readchar()
	}

	return l.input[position..l.pos]
}
