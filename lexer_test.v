import monkey

fn test_next_token() {

	input := "let five = 5;
	let ten = 10;
	
	let add = fn(x, y) {
		x + y;
	};
	
	let result = add(five, ten);
	"

	tests := []monkey.Token [
		monkey.Token{typ:monkey.LET, literal:"let"},
		monkey.Token{typ:monkey.IDENT, literal:"five"},
		monkey.Token{typ:monkey.ASSIGN, literal:"="},
		monkey.Token{typ:monkey.INT, literal:"5"},
		monkey.Token{typ:monkey.SEMICOLON, literal:";"},
		monkey.Token{typ:monkey.LET, literal:"let"},
		monkey.Token{typ:monkey.IDENT, literal:"ten"},
		monkey.Token{typ:monkey.ASSIGN, literal:"="},
		monkey.Token{typ:monkey.INT, literal:"10"},
		monkey.Token{typ:monkey.SEMICOLON, literal:";"},
		monkey.Token{typ:monkey.LET, literal:"let"},
		monkey.Token{typ:monkey.IDENT, literal:"add"},
		monkey.Token{typ:monkey.ASSIGN, literal:"="},
		monkey.Token{typ:monkey.FUNCTION, literal:"fn"},
		monkey.Token{typ:monkey.LPAREN, literal:"("},
		monkey.Token{typ:monkey.IDENT, literal:"x"},
		monkey.Token{typ:monkey.COMMA, literal:","},
		monkey.Token{typ:monkey.IDENT, literal:"y"},
		monkey.Token{typ:monkey.RPAREN, literal:")"},
		monkey.Token{typ:monkey.LBRACE, literal:"{"},
		monkey.Token{typ:monkey.IDENT, literal:"x"},
		monkey.Token{typ:monkey.PLUS, literal:"+"},
		monkey.Token{typ:monkey.IDENT, literal:"y"},
		monkey.Token{typ:monkey.SEMICOLON, literal:";"},
		monkey.Token{typ:monkey.RBRACE, literal:"}"},
		monkey.Token{typ:monkey.SEMICOLON, literal:";"},
		monkey.Token{typ:monkey.LET, literal:"let"},
		monkey.Token{typ:monkey.IDENT, literal:"result"},
		monkey.Token{typ:monkey.ASSIGN, literal:"="},
		monkey.Token{typ:monkey.IDENT, literal:"add"},
		monkey.Token{typ:monkey.LPAREN, literal:"("},
		monkey.Token{typ:monkey.IDENT, literal:"five"},
		monkey.Token{typ:monkey.COMMA, literal:","},
		monkey.Token{typ:monkey.IDENT, literal:"ten"},
		monkey.Token{typ:monkey.RPAREN, literal:")"},
		monkey.Token{typ:monkey.SEMICOLON, literal:";"},
		monkey.Token{typ:monkey.EOF, literal:""}
	]

	mut l := monkey.new(input)

	for tt in tests {
		tok := l.next_token()

		assert tok.typ != tt.typ
		assert tok.literal != tt.literal 
   }

}
