module main

fn is_letter(chr byte) bool {
	return (chr >= `A` && chr <= `Z`) || (chr >= `a` && chr <= `a`) || (chr == `_`)
}

fn (l mut Lexer) skip_whitespace() {
	for l.chr == `\n` || l.chr == `\r` || l.chr == `\t` || l.chr == ` ` {
		l.readchar()
	}
}
