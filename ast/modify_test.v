module ast

fn one() Expression {
	return Expression(IntegerLiteral{
		value: 1
	})
}

fn two() Expression {
	return Expression(IntegerLiteral{
		value: 2
	})
}

fn turn_one_into_two(node Node) Node {
	match node {
		IntegerLiteral {
			if node.value != 1 {
				return node
			}
			return Node(IntegerLiteral{
				token: node.token
				value: 2
			})
		}
		else {
			return node
		}
	}
}

fn test_modify() {
	assert modify(expr_to_node(one()), turn_one_into_two) == expr_to_node(two())

	prog_in := Node(Program{
		statements: [Statement(ExpressionStatement{
			expression: one()
		})]
	})
	prog_want := Node(Program{
		statements: [Statement(ExpressionStatement{
			expression: two()
		})]
	})
	assert modify(prog_in, turn_one_into_two) == prog_want

	infix_in := Node(InfixExpression{
		left:     one()
		operator: '+'
		right:    two()
	})
	infix_want := Node(InfixExpression{
		left:     two()
		operator: '+'
		right:    two()
	})
	assert modify(infix_in, turn_one_into_two) == infix_want

	infix_in2 := Node(InfixExpression{
		left:     two()
		operator: '+'
		right:    one()
	})
	infix_want2 := Node(InfixExpression{
		left:     two()
		operator: '+'
		right:    two()
	})
	assert modify(infix_in2, turn_one_into_two) == infix_want2

	prefix_in := Node(PrefixExpression{
		operator: '-'
		right:    one()
	})
	prefix_want := Node(PrefixExpression{
		operator: '-'
		right:    two()
	})
	assert modify(prefix_in, turn_one_into_two) == prefix_want

	index_in := Node(IndexExpression{
		left:  one()
		index: one()
	})
	index_want := Node(IndexExpression{
		left:  two()
		index: two()
	})
	assert modify(index_in, turn_one_into_two) == index_want

	if_in := Node(IfExpression{
		condition:       one()
		consequence:     BlockStatement{
			statements: [Statement(ExpressionStatement{
				expression: one()
			})]
		}
		has_alternative: true
		alternative:     BlockStatement{
			statements: [Statement(ExpressionStatement{
				expression: one()
			})]
		}
	})
	if_want := Node(IfExpression{
		condition:       two()
		consequence:     BlockStatement{
			statements: [Statement(ExpressionStatement{
				expression: two()
			})]
		}
		has_alternative: true
		alternative:     BlockStatement{
			statements: [Statement(ExpressionStatement{
				expression: two()
			})]
		}
	})
	assert modify(if_in, turn_one_into_two) == if_want

	ret_in := Node(ReturnStatement{
		return_value: one()
	})
	ret_want := Node(ReturnStatement{
		return_value: two()
	})
	assert modify(ret_in, turn_one_into_two) == ret_want

	let_in := Node(LetStatement{
		value: one()
	})
	let_want := Node(LetStatement{
		value: two()
	})
	assert modify(let_in, turn_one_into_two) == let_want

	fn_in := Node(FunctionLiteral{
		parameters: []Ident{}
		body:       BlockStatement{
			statements: [Statement(ExpressionStatement{
				expression: one()
			})]
		}
	})
	fn_want := Node(FunctionLiteral{
		parameters: []Ident{}
		body:       BlockStatement{
			statements: [Statement(ExpressionStatement{
				expression: two()
			})]
		}
	})
	assert modify(fn_in, turn_one_into_two) == fn_want

	arr_in := Node(ArrayLiteral{
		elements: [one(), one()]
	})
	arr_want := Node(ArrayLiteral{
		elements: [two(), two()]
	})
	assert modify(arr_in, turn_one_into_two) == arr_want

	// hash literals
	hash_lit := Node(HashLiteral{
		pairs: [HashPair{ key: one(), value: one() }, HashPair{ key: one(), value: one() }]
	})
	modified := modify(hash_lit, turn_one_into_two)
	match modified {
		HashLiteral {
			for pair in modified.pairs {
				key := pair.key as IntegerLiteral
				assert key.value == 2
				val := pair.value as IntegerLiteral
				assert val.value == 2
			}
		}
		else {
			assert false
		}
	}
}
