module monkey

pub struct Lexer {
mut:
	input   string
	pos     int // current position in input (points to current char)
	readpos int // current read position in input (after current char)
	chr     byte // current char under examination
}

pub fn new(input string) &Lexer {
	mut l := &Lexer{
		input: input
	}
	l.readchar()
	return l
}

fn is_letter(chr byte) bool {
	return (chr >= `A` && chr <= `Z`) || (chr >= `a` && chr <= `a`) || (chr == `_`)
}

fn (mut l Lexer) skip_whitespace() {
	for l.chr == `\n` || l.chr == `\r` || l.chr == `\t` || l.chr == ` ` {
		l.readchar()
	}
}

pub fn (mut l Lexer) readchar() {
	if l.readpos >= l.input.len {
		l.chr = 0
	} else {
		l.chr = l.input[l.readpos]
		l.pos = l.readpos
		l.readpos++
	}
}

fn new_token(tokentype string, ch byte) Token {
	return Token{
		typ: tokentype
		literal: tos2(ch)
	}
}

pub fn (mut l Lexer) next_token() Token {
	mut tok := Token{}
	l.skip_whitespace()
	match l.chr {
		`=` {
			tok = new_token(assign, l.chr)
		}
		`+` {
			tok = new_token(plus, l.chr)
		}
		`;` {
			tok = new_token(semicolon, l.chr)
		}
		`{` {
			tok = new_token(lbrace, l.chr)
		}
		`}` {
			tok = new_token(rbrace, l.chr)
		}
		`-` {
			tok = new_token(minus, l.chr)
		}
		`>` {
			tok = new_token(gt, l.chr)
		}
		`<` {
			tok = new_token(lt, l.chr)
		}
		`,` {
			tok = new_token(comma, l.chr)
		}
		`/` {
			tok = new_token(slash, l.chr)
		}
		`*` {
			tok = new_token(asterisk, l.chr)
		}
		0 {
			tok.literal = ''
			tok.typ = eof
		}
		else {
			if is_letter(l.chr) {
				tok.literal = l.read_identifier()
				tok.typ = lookup_ident(tok.literal)
				return tok
			} else {
				tok = new_token(illegal, l.chr)
			}
		}
	}
	l.readchar()
	return tok
}

pub fn (mut l Lexer) read_identifier() string {
	position := l.pos
	for is_letter(l.chr) {
		l.readchar()
	}
	return l.input[position..l.pos]
}
