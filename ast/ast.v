module ast

import token

// Statement represents a statement node.
pub type Statement = ExpressionStatement | LetStatement | ReturnStatement

// Expression represents an expression node.
pub type Expression = ArrayLiteral
	| Boolean
	| CallExpression
	| FloatLiteral
	| FunctionLiteral
	| HashLiteral
	| Ident
	| IfExpression
	| IndexExpression
	| InfixExpression
	| IntegerLiteral
	| MacroLiteral
	| PrefixExpression
	| StringLiteral

// Node represents any node of the AST. It is mainly used by `modify`.
pub type Node = ArrayLiteral
	| Boolean
	| BlockStatement
	| CallExpression
	| ExpressionStatement
	| FloatLiteral
	| FunctionLiteral
	| HashLiteral
	| Ident
	| IfExpression
	| IndexExpression
	| InfixExpression
	| IntegerLiteral
	| LetStatement
	| MacroLiteral
	| PrefixExpression
	| Program
	| ReturnStatement
	| StringLiteral

// Program is the top-level AST node of a program.
pub struct Program {
pub mut:
	statements []Statement
}

pub fn (p Program) token_literal() string {
	if p.statements.len > 0 {
		return p.statements[0].token_literal()
	}
	return ''
}

pub fn (p Program) str() string {
	return p.statements.map(it.str()).join('')
}

// Ident represents an identifier.
pub struct Ident {
pub:
	token token.Token // the token.ident token
	value string
}

pub fn (i Ident) token_literal() string {
	return i.token.literal
}

pub fn (i Ident) str() string {
	return i.value
}

// LetStatement represents a `let` statement.
pub struct LetStatement {
pub:
	token token.Token // the token.key_let token
	name  Ident
	value Expression
}

pub fn (ls LetStatement) token_literal() string {
	return ls.token.literal
}

pub fn (ls LetStatement) str() string {
	return '${ls.token_literal()} ${ls.name.str()} = ${ls.value.str()};'
}

// ReturnStatement represents a `return` statement.
pub struct ReturnStatement {
pub:
	token        token.Token // the token.key_return token
	return_value Expression
}

pub fn (rs ReturnStatement) token_literal() string {
	return rs.token.literal
}

pub fn (rs ReturnStatement) str() string {
	return '${rs.token_literal()} ${rs.return_value.str()};'
}

// ExpressionStatement represents a statement consisting of a single expression.
pub struct ExpressionStatement {
pub:
	token      token.Token // the first token of the expression
	expression Expression
}

pub fn (es ExpressionStatement) token_literal() string {
	return es.token.literal
}

pub fn (es ExpressionStatement) str() string {
	return es.expression.str()
}

// BlockStatement represents a `{ ... }` block.
pub struct BlockStatement {
pub:
	token      token.Token // the '{' token
	statements []Statement
}

pub fn (bs BlockStatement) token_literal() string {
	return bs.token.literal
}

pub fn (bs BlockStatement) str() string {
	return bs.statements.map(it.str()).join('')
}

// IntegerLiteral represents an integer literal.
pub struct IntegerLiteral {
pub:
	token token.Token
	value i64
}

pub fn (il IntegerLiteral) token_literal() string {
	return il.token.literal
}

pub fn (il IntegerLiteral) str() string {
	return il.token.literal
}

// FloatLiteral represents a floating point number literal.
pub struct FloatLiteral {
pub:
	token token.Token
	value f64
}

pub fn (fl FloatLiteral) token_literal() string {
	return fl.token.literal
}

pub fn (fl FloatLiteral) str() string {
	return fl.token.literal
}

// Boolean represents a boolean literal.
pub struct Boolean {
pub:
	token token.Token
	value bool
}

pub fn (b Boolean) token_literal() string {
	return b.token.literal
}

pub fn (b Boolean) str() string {
	return b.token.literal
}

// StringLiteral represents a string literal.
pub struct StringLiteral {
pub:
	token token.Token
	value string
}

pub fn (sl StringLiteral) token_literal() string {
	return sl.token.literal
}

pub fn (sl StringLiteral) str() string {
	return sl.token.literal
}

// PrefixExpression represents a prefix expression, e.g. `!x`.
pub struct PrefixExpression {
pub:
	token    token.Token // the prefix token, e.g. `!`
	operator string
	right    Expression
}

pub fn (pe PrefixExpression) token_literal() string {
	return pe.token.literal
}

pub fn (pe PrefixExpression) str() string {
	return '(${pe.operator}${pe.right.str()})'
}

// InfixExpression represents an infix expression, e.g. `x + y`.
pub struct InfixExpression {
pub:
	token    token.Token // the operator token, e.g. `+`
	left     Expression
	operator string
	right    Expression
}

pub fn (ie InfixExpression) token_literal() string {
	return ie.token.literal
}

pub fn (ie InfixExpression) str() string {
	return '(${ie.left.str()} ${ie.operator} ${ie.right.str()})'
}

// IfExpression represents an `if` expression.
pub struct IfExpression {
pub:
	token           token.Token // the 'if' token
	condition       Expression
	consequence     BlockStatement
	has_alternative bool
	alternative     BlockStatement
}

pub fn (ie IfExpression) token_literal() string {
	return ie.token.literal
}

pub fn (ie IfExpression) str() string {
	mut out := 'if${ie.condition.str()} ${ie.consequence.str()}'
	if ie.has_alternative {
		out += 'else ${ie.alternative.str()}'
	}
	return out
}

// FunctionLiteral represents a function literal.
pub struct FunctionLiteral {
pub:
	token      token.Token // the 'fn' token
	parameters []Ident
	body       BlockStatement
}

pub fn (fl FunctionLiteral) token_literal() string {
	return fl.token.literal
}

pub fn (fl FunctionLiteral) str() string {
	params := fl.parameters.map(it.str()).join(', ')
	return '${fl.token_literal()}(${params}) ${fl.body.str()}'
}

// CallExpression represents a function call expression.
pub struct CallExpression {
pub:
	token     token.Token // the '(' token
	function  Expression  // Ident or FunctionLiteral
	arguments []Expression
}

pub fn (ce CallExpression) token_literal() string {
	return ce.token.literal
}

pub fn (ce CallExpression) str() string {
	args := ce.arguments.map(it.str()).join(', ')
	return '${ce.function.str()}(${args})'
}

// ArrayLiteral represents an array literal.
pub struct ArrayLiteral {
pub:
	token    token.Token // the '[' token
	elements []Expression
}

pub fn (al ArrayLiteral) token_literal() string {
	return al.token.literal
}

pub fn (al ArrayLiteral) str() string {
	elements := al.elements.map(it.str()).join(', ')
	return '[${elements}]'
}

// IndexExpression represents an array/hash index expression, e.g. `arr[0]`.
pub struct IndexExpression {
pub:
	token token.Token // the '[' token
	left  Expression
	index Expression
}

pub fn (ie IndexExpression) token_literal() string {
	return ie.token.literal
}

pub fn (ie IndexExpression) str() string {
	return '(${ie.left.str()}[${ie.index.str()}])'
}

// HashPair represents a key-value pair in a hash literal.
pub struct HashPair {
pub:
	key   Expression
	value Expression
}

// HashLiteral represents a hash literal.
pub struct HashLiteral {
pub:
	token token.Token // the '{' token
	pairs []HashPair
}

pub fn (hl HashLiteral) token_literal() string {
	return hl.token.literal
}

pub fn (hl HashLiteral) str() string {
	pairs := hl.pairs.map('${it.key.str()}: ${it.value.str()}').join(', ')
	return '{${pairs}}'
}

// MacroLiteral represents a `macro` literal.
pub struct MacroLiteral {
pub:
	token      token.Token // the 'macro' token
	parameters []Ident
	body       BlockStatement
}

pub fn (ml MacroLiteral) token_literal() string {
	return ml.token.literal
}

pub fn (ml MacroLiteral) str() string {
	params := ml.parameters.map(it.str()).join(', ')
	return '${ml.token_literal()}(${params}) ${ml.body.str()}'
}

// Statement dispatch

pub fn (s Statement) token_literal() string {
	return match s {
		LetStatement { s.token_literal() }
		ReturnStatement { s.token_literal() }
		ExpressionStatement { s.token_literal() }
	}
}

pub fn (s Statement) str() string {
	return match s {
		LetStatement { s.str() }
		ReturnStatement { s.str() }
		ExpressionStatement { s.str() }
	}
}

// Expression dispatch

pub fn (e Expression) token_literal() string {
	return match e {
		Ident { e.token_literal() }
		IntegerLiteral { e.token_literal() }
		FloatLiteral { e.token_literal() }
		Boolean { e.token_literal() }
		StringLiteral { e.token_literal() }
		PrefixExpression { e.token_literal() }
		InfixExpression { e.token_literal() }
		IfExpression { e.token_literal() }
		FunctionLiteral { e.token_literal() }
		CallExpression { e.token_literal() }
		ArrayLiteral { e.token_literal() }
		IndexExpression { e.token_literal() }
		HashLiteral { e.token_literal() }
		MacroLiteral { e.token_literal() }
	}
}

pub fn (e Expression) str() string {
	return match e {
		Ident { e.str() }
		IntegerLiteral { e.str() }
		FloatLiteral { e.str() }
		Boolean { e.str() }
		StringLiteral { e.str() }
		PrefixExpression { e.str() }
		InfixExpression { e.str() }
		IfExpression { e.str() }
		FunctionLiteral { e.str() }
		CallExpression { e.str() }
		ArrayLiteral { e.str() }
		IndexExpression { e.str() }
		HashLiteral { e.str() }
		MacroLiteral { e.str() }
	}
}

// Node dispatch

pub fn (n Node) token_literal() string {
	return match n {
		Program { n.token_literal() }
		LetStatement { n.token_literal() }
		ReturnStatement { n.token_literal() }
		ExpressionStatement { n.token_literal() }
		BlockStatement { n.token_literal() }
		Ident { n.token_literal() }
		IntegerLiteral { n.token_literal() }
		FloatLiteral { n.token_literal() }
		Boolean { n.token_literal() }
		StringLiteral { n.token_literal() }
		PrefixExpression { n.token_literal() }
		InfixExpression { n.token_literal() }
		IfExpression { n.token_literal() }
		FunctionLiteral { n.token_literal() }
		CallExpression { n.token_literal() }
		ArrayLiteral { n.token_literal() }
		IndexExpression { n.token_literal() }
		HashLiteral { n.token_literal() }
		MacroLiteral { n.token_literal() }
	}
}

pub fn (n Node) str() string {
	return match n {
		Program { n.str() }
		LetStatement { n.str() }
		ReturnStatement { n.str() }
		ExpressionStatement { n.str() }
		BlockStatement { n.str() }
		Ident { n.str() }
		IntegerLiteral { n.str() }
		FloatLiteral { n.str() }
		Boolean { n.str() }
		StringLiteral { n.str() }
		PrefixExpression { n.str() }
		InfixExpression { n.str() }
		IfExpression { n.str() }
		FunctionLiteral { n.str() }
		CallExpression { n.str() }
		ArrayLiteral { n.str() }
		IndexExpression { n.str() }
		HashLiteral { n.str() }
		MacroLiteral { n.str() }
	}
}

// Node/Statement/Expression conversions

pub fn stmt_to_node(s Statement) Node {
	match s {
		LetStatement { return Node(s) }
		ReturnStatement { return Node(s) }
		ExpressionStatement { return Node(s) }
	}
}

pub fn expr_to_node(e Expression) Node {
	match e {
		Ident { return Node(e) }
		IntegerLiteral { return Node(e) }
		FloatLiteral { return Node(e) }
		Boolean { return Node(e) }
		StringLiteral { return Node(e) }
		PrefixExpression { return Node(e) }
		InfixExpression { return Node(e) }
		IfExpression { return Node(e) }
		FunctionLiteral { return Node(e) }
		CallExpression { return Node(e) }
		ArrayLiteral { return Node(e) }
		IndexExpression { return Node(e) }
		HashLiteral { return Node(e) }
		MacroLiteral { return Node(e) }
	}
}

pub fn node_as_statement(n Node) Statement {
	match n {
		LetStatement { return n }
		ReturnStatement { return n }
		ExpressionStatement { return n }
		else { panic('ast: node is not a Statement') }
	}
}

pub fn node_as_expression(n Node) Expression {
	match n {
		Ident { return n }
		IntegerLiteral { return n }
		FloatLiteral { return n }
		Boolean { return n }
		StringLiteral { return n }
		PrefixExpression { return n }
		InfixExpression { return n }
		IfExpression { return n }
		FunctionLiteral { return n }
		CallExpression { return n }
		ArrayLiteral { return n }
		IndexExpression { return n }
		HashLiteral { return n }
		MacroLiteral { return n }
		else { panic('ast: node is not an Expression') }
	}
}

pub fn node_as_ident(n Node) Ident {
	match n {
		Ident { return n }
		else { panic('ast: node is not an Ident') }
	}
}

pub fn node_as_block(n Node) BlockStatement {
	match n {
		BlockStatement { return n }
		else { panic('ast: node is not a BlockStatement') }
	}
}
