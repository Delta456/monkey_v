module ast

import token
import strings

pub type Node = LetStatement | ReturnStatement

pub type Statement = FnStatement | LetStatement | ReturnStatement

pub type Expression = ExpressionStatement | FnStatement | Identifier | IntegerExpression |
	StringExpression

pub struct Program {
pub:
	statements []Statement
}

pub fn (p Program) str() string {
	mut sb := strings.Builder{}
	for s in p.statements {
		// sb.write(s.str())
		match s {
			LetStatement { sb.write(s.str()) }
			ReturnStatement {sb.write(s.str())}
			else {}
		}
	}
	return sb.str()
}

pub fn (p Program) token_literals() string {
	if p.statements.len > 0 {
		return p.statements[0].token_literal()
	}
	return ''
}

pub struct Identifier {
pub:
	token token.Token
	value string
}

pub fn (ident Identifier) str() string {
	return ident.value
}

pub fn (stmt Statement) token_literal() string {
	match stmt {
		LetStatement {
			return stmt.token_literal()
		}
		ReturnStatement {
			return stmt.token_literal()
		}
		else {}
	}
}

pub struct LetStatement {
pub:
	token     token.Token
	name      Identifier
	has_value bool
	value     Expression
}

pub fn (ls LetStatement) str() string {
	mut sb := strings.Builder{}
	sb.write(ls.token_literal() + ' ')
	sb.write(ls.name.str())
	sb.write(' = ')
	/*
	if ls.value is FnStatement | Identifier | IntegerExpression | StringExpression | ExpressionStatement
		sb.write(ls.value)
	}
	*/
	sb.write(';')
	return sb.str()
}

pub fn (ls LetStatement) token_literal() string {
	return ls.name.token.literal
}

pub struct StringExpression {
	value string
}

pub struct IntegerExpression {
	value string
}

pub struct ReturnStatement {
	token        token.Token // the `return` token
	return_value Expression
}

pub fn (rs ReturnStatement) token_literal() string {
	return rs.token.literal
}

pub fn (rs ReturnStatement) str() string {
	mut sb := strings.Builder{}

	sb.write(rs.token_literal() + ' ')
	/*
	if rs.value is FnStatement | Identifier | IntegerExpression | StringExpression | ExpressionStatement
		sb.write(rs.value)
	}
	*/
	sb.write(';')
	return sb.str()
}

pub struct FnStatement {
pub:
	token     token.Token
	anonym    bool
	name      Identifier
	parameter []Identifier
	stmts     []Statement
}

pub struct ExpressionStatement {
pub:
	token      token.Token // the first token of the exprression 
	expression Expression
}

pub fn (expstmt ExpressionStatement) token_literal() string {
	return expstmt.token.literal
}
