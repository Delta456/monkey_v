module monkey

struct Parser {
	l Lexer
  mut:
	cur_token Token
	peek_token Token
}

fn new_parser(l Lexer) &Parser {
	mut p := &Parser{l : l}

	// Read two tokens, so cur_token and peek_token are both set
	p.next_token()
	p.next_token()

	return p
}

fn (p mut Parser) next_token() {
	p.cur_token = p.peek_token
	p.peek_token = p.l.next_token()
}
