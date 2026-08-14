module ast

import token

fn test_string() {
	program := Program{
		statements: [
			Statement(LetStatement{
				token: token.Token{
					typ:     token.key_let
					literal: 'let'
				}
				name:  Ident{
					token: token.Token{
						typ:     token.ident
						literal: 'myVar'
					}
					value: 'myVar'
				}
				value: Expression(Ident{
					token: token.Token{
						typ:     token.ident
						literal: 'anotherVar'
					}
					value: 'anotherVar'
				})
			}),
		]
	}

	assert program.str() == 'let myVar = anotherVar;'
}
