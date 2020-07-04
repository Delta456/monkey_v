module monkey

interface monkey.Noder {
	token_literal() string
}

interface monkey.Statementer {
	statement_node()
}

interface monkey.Expressioner {
	expression_node()
}

struct Program {
	statements []Statmenter
}

fn (mut p Program) token_literal() string {
	if p.statements.len > 0 {
		return p.statements[0].token_literal()
	} else {
		return ''
	}
}

struct LetStatment {
	token token
	name  Identifier
	value Expressioner
}

fn (ls LetStatment) statement_node() {
	return
}

fn (ls LetStatment) token_literal() string {
	return ls.token.literal
}
