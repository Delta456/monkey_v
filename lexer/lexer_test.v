module lexer

import token

fn test_next_token() {
	input := '
	let five = 5;
	let ten = 10;
	let add = fn(x, y) {
		x + y;
	};
	let result = add(five, ten);
	!-/*0;
	2 < 10 > 7;

	if (5 < 10) {
		return true;
	} else {
		return false;
	}

	10 == 10;
	10 != 9;

	"foobar";
	"foo bar";

	[1, 2];

	{"foo": "bar"};

	// comment
	let a = 1; // inline comment

	let b = 123.45;
	let c = 0.678;
	let d = 9.0;

	macro(x, y) { x + y; };
	'

	tests := [
		TestToken{token.key_let, 'let'},
		TestToken{token.ident, 'five'},
		TestToken{token.assign, '='},
		TestToken{token.int_tok, '5'},
		TestToken{token.semicolon, ';'},
		TestToken{token.key_let, 'let'},
		TestToken{token.ident, 'ten'},
		TestToken{token.assign, '='},
		TestToken{token.int_tok, '10'},
		TestToken{token.semicolon, ';'},
		TestToken{token.key_let, 'let'},
		TestToken{token.ident, 'add'},
		TestToken{token.assign, '='},
		TestToken{token.key_function, 'fn'},
		TestToken{token.lparen, '('},
		TestToken{token.ident, 'x'},
		TestToken{token.comma, ','},
		TestToken{token.ident, 'y'},
		TestToken{token.rparen, ')'},
		TestToken{token.lbrace, '{'},
		TestToken{token.ident, 'x'},
		TestToken{token.plus, '+'},
		TestToken{token.ident, 'y'},
		TestToken{token.semicolon, ';'},
		TestToken{token.rbrace, '}'},
		TestToken{token.semicolon, ';'},
		TestToken{token.key_let, 'let'},
		TestToken{token.ident, 'result'},
		TestToken{token.assign, '='},
		TestToken{token.ident, 'add'},
		TestToken{token.lparen, '('},
		TestToken{token.ident, 'five'},
		TestToken{token.comma, ','},
		TestToken{token.ident, 'ten'},
		TestToken{token.rparen, ')'},
		TestToken{token.semicolon, ';'},
		TestToken{token.bang, '!'},
		TestToken{token.minus, '-'},
		TestToken{token.slash, '/'},
		TestToken{token.asterisk, '*'},
		TestToken{token.int_tok, '0'},
		TestToken{token.semicolon, ';'},
		TestToken{token.int_tok, '2'},
		TestToken{token.lt, '<'},
		TestToken{token.int_tok, '10'},
		TestToken{token.gt, '>'},
		TestToken{token.int_tok, '7'},
		TestToken{token.semicolon, ';'},
		TestToken{token.key_if, 'if'},
		TestToken{token.lparen, '('},
		TestToken{token.int_tok, '5'},
		TestToken{token.lt, '<'},
		TestToken{token.int_tok, '10'},
		TestToken{token.rparen, ')'},
		TestToken{token.lbrace, '{'},
		TestToken{token.key_return, 'return'},
		TestToken{token.key_true, 'true'},
		TestToken{token.semicolon, ';'},
		TestToken{token.rbrace, '}'},
		TestToken{token.key_else, 'else'},
		TestToken{token.lbrace, '{'},
		TestToken{token.key_return, 'return'},
		TestToken{token.key_false, 'false'},
		TestToken{token.semicolon, ';'},
		TestToken{token.rbrace, '}'},
		TestToken{token.int_tok, '10'},
		TestToken{token.eq, '=='},
		TestToken{token.int_tok, '10'},
		TestToken{token.semicolon, ';'},
		TestToken{token.int_tok, '10'},
		TestToken{token.not_eq, '!='},
		TestToken{token.int_tok, '9'},
		TestToken{token.semicolon, ';'},
		TestToken{token.str, 'foobar'},
		TestToken{token.semicolon, ';'},
		TestToken{token.str, 'foo bar'},
		TestToken{token.semicolon, ';'},
		TestToken{token.lbracket, '['},
		TestToken{token.int_tok, '1'},
		TestToken{token.comma, ','},
		TestToken{token.int_tok, '2'},
		TestToken{token.rbracket, ']'},
		TestToken{token.semicolon, ';'},
		TestToken{token.lbrace, '{'},
		TestToken{token.str, 'foo'},
		TestToken{token.colon, ':'},
		TestToken{token.str, 'bar'},
		TestToken{token.rbrace, '}'},
		TestToken{token.semicolon, ';'},
		TestToken{token.key_let, 'let'},
		TestToken{token.ident, 'a'},
		TestToken{token.assign, '='},
		TestToken{token.int_tok, '1'},
		TestToken{token.semicolon, ';'},
		TestToken{token.key_let, 'let'},
		TestToken{token.ident, 'b'},
		TestToken{token.assign, '='},
		TestToken{token.float_tok, '123.45'},
		TestToken{token.semicolon, ';'},
		TestToken{token.key_let, 'let'},
		TestToken{token.ident, 'c'},
		TestToken{token.assign, '='},
		TestToken{token.float_tok, '0.678'},
		TestToken{token.semicolon, ';'},
		TestToken{token.key_let, 'let'},
		TestToken{token.ident, 'd'},
		TestToken{token.assign, '='},
		TestToken{token.float_tok, '9.0'},
		TestToken{token.semicolon, ';'},
		TestToken{token.key_macro, 'macro'},
		TestToken{token.lparen, '('},
		TestToken{token.ident, 'x'},
		TestToken{token.comma, ','},
		TestToken{token.ident, 'y'},
		TestToken{token.rparen, ')'},
		TestToken{token.lbrace, '{'},
		TestToken{token.ident, 'x'},
		TestToken{token.plus, '+'},
		TestToken{token.ident, 'y'},
		TestToken{token.semicolon, ';'},
		TestToken{token.rbrace, '}'},
		TestToken{token.semicolon, ';'},
		TestToken{token.eof, ''},
	]

	mut l := new(input)

	for i, tt in tests {
		tok := l.next_token()

		assert tok.typ == tt.expected_type, 'tests[${i}] - token type wrong. expected=${tt.expected_type}, got=${tok.typ}'
		assert tok.literal == tt.expected_literal, 'tests[${i}] - literal wrong. expected=${tt.expected_literal}, got=${tok.literal}'
	}
}

struct TestToken {
	expected_type    token.Type
	expected_literal string
}
