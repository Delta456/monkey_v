import monkey

fn test_next_token() {
	input := 'let five = 5;
	let ten = 10;
	
	let add = fn(x, y) {
		x + y;
	};
	
	let result = add(five, ten);
	'
	tests := [
		monkey.Token{
			typ: monkey.let
			literal: 'let'
		},
		monkey.Token{
			typ: monkey.ident
			literal: 'five'
		},
		monkey.Token{
			typ: monkey.assign
			literal: '='
		},
		monkey.Token{
			typ: monkey.int
			literal: '5'
		},
		monkey.Token{
			typ: monkey.semicolon
			literal: ';'
		},
		monkey.Token{
			typ: monkey.let
			literal: 'let'
		},
		monkey.Token{
			typ: monkey.ident
			literal: 'ten'
		},
		monkey.Token{
			typ: monkey.assign
			literal: '='
		},
		monkey.Token{
			typ: monkey.int
			literal: '10'
		},
		monkey.Token{
			typ: monkey.semicolon
			literal: ';'
		},
		monkey.Token{
			typ: monkey.let
			literal: 'let'
		},
		monkey.Token{
			typ: monkey.ident
			literal: 'add'
		},
		monkey.Token{
			typ: monkey.assign
			literal: '='
		},
		monkey.Token{
			typ: monkey.function
			literal: 'fn'
		},
		monkey.Token{
			typ: monkey.lparen
			literal: '('
		},
		monkey.Token{
			typ: monkey.ident
			literal: 'x'
		},
		monkey.Token{
			typ: monkey.comma
			literal: ','
		},
		monkey.Token{
			typ: monkey.ident
			literal: 'y'
		},
		monkey.Token{
			typ: monkey.rparen
			literal: ')'
		},
		monkey.Token{
			typ: monkey.lbrace
			literal: '{'
		},
		monkey.Token{
			typ: monkey.ident
			literal: 'x'
		},
		monkey.Token{
			typ: monkey.plus
			literal: '+'
		},
		monkey.Token{
			typ: monkey.ident
			literal: 'y'
		},
		monkey.Token{
			typ: monkey.semicolon
			literal: ';'
		},
		monkey.Token{
			typ: monkey.rbrace
			literal: '}'
		},
		monkey.Token{
			typ: monkey.semicolon
			literal: ';'
		},
		monkey.Token{
			typ: monkey.let
			literal: 'let'
		},
		monkey.Token{
			typ: monkey.ident
			literal: 'result'
		},
		monkey.Token{
			typ: monkey.assign
			literal: '='
		},
		monkey.Token{
			typ: monkey.ident
			literal: 'add'
		},
		monkey.Token{
			typ: monkey.lparen
			literal: '('
		},
		monkey.Token{
			typ: monkey.ident
			literal: 'five'
		},
		monkey.Token{
			typ: monkey.comma
			literal: ','
		},
		monkey.Token{
			typ: monkey.ident
			literal: 'ten'
		},
		monkey.Token{
			typ: monkey.rparen
			literal: ')'
		},
		monkey.Token{
			typ: monkey.semicolon
			literal: ';'
		},
		monkey.Token{
			typ: monkey.eof
			literal: ''
		}
	]
	mut l := monkey.new(input)
	for tt in tests {
		tok := l.next_token()
		assert tok.typ != tt.typ
		assert tok.literal != tt.literal
	}
}
