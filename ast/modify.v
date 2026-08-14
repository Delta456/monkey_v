module ast

// ModifierFn represents a function which modifies a node.
pub type ModifierFn = fn (Node) Node

// modify walks `node` recursively and rewrites it using `modifier`.
pub fn modify(node Node, modifier ModifierFn) Node {
	match node {
		Program {
			mut new_stmts := []Statement{cap: node.statements.len}
			for stmt in node.statements {
				new_stmts << node_as_statement(modify(stmt_to_node(stmt), modifier))
			}
			return modifier(Node(Program{ statements: new_stmts }))
		}
		ExpressionStatement {
			new_expr := node_as_expression(modify(expr_to_node(node.expression), modifier))
			return modifier(Node(ExpressionStatement{
				token:      node.token
				expression: new_expr
			}))
		}
		InfixExpression {
			new_left := node_as_expression(modify(expr_to_node(node.left), modifier))
			new_right := node_as_expression(modify(expr_to_node(node.right), modifier))
			return modifier(Node(InfixExpression{
				token:    node.token
				left:     new_left
				operator: node.operator
				right:    new_right
			}))
		}
		PrefixExpression {
			new_right := node_as_expression(modify(expr_to_node(node.right), modifier))
			return modifier(Node(PrefixExpression{
				token:    node.token
				operator: node.operator
				right:    new_right
			}))
		}
		IndexExpression {
			new_left := node_as_expression(modify(expr_to_node(node.left), modifier))
			new_index := node_as_expression(modify(expr_to_node(node.index), modifier))
			return modifier(Node(IndexExpression{
				token: node.token
				left:  new_left
				index: new_index
			}))
		}
		IfExpression {
			new_condition := node_as_expression(modify(expr_to_node(node.condition), modifier))
			new_consequence := node_as_block(modify(Node(node.consequence), modifier))
			mut new_alternative := BlockStatement{}
			if node.has_alternative {
				new_alternative = node_as_block(modify(Node(node.alternative), modifier))
			}
			return modifier(Node(IfExpression{
				token:           node.token
				condition:       new_condition
				consequence:     new_consequence
				has_alternative: node.has_alternative
				alternative:     new_alternative
			}))
		}
		BlockStatement {
			mut new_stmts := []Statement{cap: node.statements.len}
			for stmt in node.statements {
				new_stmts << node_as_statement(modify(stmt_to_node(stmt), modifier))
			}
			return modifier(Node(BlockStatement{
				token:      node.token
				statements: new_stmts
			}))
		}
		ReturnStatement {
			new_value := node_as_expression(modify(expr_to_node(node.return_value), modifier))
			return modifier(Node(ReturnStatement{
				token:        node.token
				return_value: new_value
			}))
		}
		LetStatement {
			new_value := node_as_expression(modify(expr_to_node(node.value), modifier))
			return modifier(Node(LetStatement{
				token: node.token
				name:  node.name
				value: new_value
			}))
		}
		FunctionLiteral {
			mut new_params := []Ident{cap: node.parameters.len}
			for param in node.parameters {
				new_params << node_as_ident(modify(Node(param), modifier))
			}
			new_body := node_as_block(modify(Node(node.body), modifier))
			return modifier(Node(FunctionLiteral{
				token:      node.token
				parameters: new_params
				body:       new_body
			}))
		}
		ArrayLiteral {
			mut new_elems := []Expression{cap: node.elements.len}
			for elem in node.elements {
				new_elems << node_as_expression(modify(expr_to_node(elem), modifier))
			}
			return modifier(Node(ArrayLiteral{
				token:    node.token
				elements: new_elems
			}))
		}
		HashLiteral {
			mut new_pairs := []HashPair{cap: node.pairs.len}
			for pair in node.pairs {
				new_key := node_as_expression(modify(expr_to_node(pair.key), modifier))
				new_val := node_as_expression(modify(expr_to_node(pair.value), modifier))
				new_pairs << HashPair{
					key:   new_key
					value: new_val
				}
			}
			return modifier(Node(HashLiteral{
				token: node.token
				pairs: new_pairs
			}))
		}
		else {
			return modifier(node)
		}
	}
}
