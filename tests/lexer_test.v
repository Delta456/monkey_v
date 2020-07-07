import lexer
import token

struct TestToken {
	expected_type    string
	expected_literal string
}

fn test_next_token() {
	input := '+ = ( ) { } , ;'
	tests := [token.Token{token.plus, '+'},
		token.Token{token.assign, '='}, token.Token{token.l_paren, '('},
		token.Token{token.r_paren, ')'},
		token.Token{token.l_brace, '{'}, token.Token{token.r_brace, '}'},
		token.Token{token.colon, ','}, token.Token{token.semicolon, ';'},
		token.Token{token.eof, ''}
	]
	mut l := lexer.new(input)
	for i, tt in tests {
		tok := l.next_token()
		if tok.typ != tt.typ {
			eprintln('tests[$i] - tokentype wrong. expected = `$tt.typ` , got = `$tok.typ`')
			assert false
		}
		if tok.literal != tt.literal {
			eprintln('tests[$i] - literal wrong. expected = `$tt.literal` , got = `$tok.literal`')
			assert false
		}
	}
}

fn test_next_token_basic2() {
	input := '
	        let five = 5;
	        let ten = 10;
	
	        let add = fn(x, y) {
		       x + y;
	        };
			!=
			==
			else if
			return
			true 
			false
			'
	tests := [TestToken{token.key_let, 'let'},
		TestToken{token.ident, 'five'}, TestToken{token.assign, '='},
		TestToken{token.int, '5'}, TestToken{token.semicolon, ';'},
		TestToken{token.key_let, 'let'}, TestToken{token.ident, 'ten'},
		TestToken{token.assign, '='}, TestToken{token.int, '10'},
		TestToken{token.semicolon, ';'},
		TestToken{token.key_let, 'let'}, TestToken{token.ident, 'add'},
		TestToken{token.assign, '='}, TestToken{token.key_function, 'fn'},
		TestToken{token.l_paren, '('}, TestToken{token.ident, 'x'},
		TestToken{token.colon, ','}, TestToken{token.ident, 'y'},
		TestToken{token.r_paren, ')'}, TestToken{token.l_brace, '{'},
		TestToken{token.ident, 'x'}, TestToken{token.plus, '+'},
		TestToken{token.ident, 'y'},
		TestToken{token.semicolon, ';'}, TestToken{token.r_brace, '}'},
		TestToken{token.semicolon, ';'}, TestToken{token.not_eq, '!='},
		TestToken{token.eq, '=='}, TestToken{token.key_else, 'else'},
		TestToken{token.key_if, 'if'}, TestToken{token.key_return, 'return'},
		TestToken{token.key_true, 'true'}, TestToken{token.key_false, 'false'}]
		
	mut l := lexer.new(input)
	for i, tt in tests {
		tok := l.next_token()
		if tok.typ != tt.expected_type {
			eprintln('tests[$i] - tokentype wrong. expected=$tt.expected_type , got=$tok.typ')
			assert false
		}
		if tok.literal != tt.expected_literal {
			eprintln('tests[$i] - literal wrong. expected=$tt.expected_literal , got=$tok.literal')
			assert false
		}
	}
}
