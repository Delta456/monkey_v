module monkey

struct parser {
	l lexer
	cur_token token
	peek_token poken
}

fn new_parser(l lexer) &parser {
	p := &Parser{l : l}

	// Read two tokens, so cur_token and peek_token are both set
	p.next_token()
	p.next_token()

	return p
}

fn (p mut parser) next_token() {
	p.cur_token = p.peek_token
	p.peek_token = p.l.next_token()
}
