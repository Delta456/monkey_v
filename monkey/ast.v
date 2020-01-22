module monkey

// TODO: Interface doesn't work and uncomment when it is done

/*
interface Noder {
	token_literal() string
}

interface Statementer {
	noder
	statement_node()
}

interface Expressioner {
	noder
	expression_node()
}


struct Program {
	statements []Statmenter
}

fn (p mut Program) token_literal() string {
	if p.statements.len > 0 {
       return p.statements[0].token_literal()
	}
	else {
		return ''
	}
}

struct LetStatment {
	token token
	name Identifier
	value Expressioner
}

fn (ls LetStatment) statement_node() { return None }

fn (ls LetStatment) token_literal() string {
	return ls.token.literal
}
*/
