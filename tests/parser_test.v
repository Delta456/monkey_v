import parser
import ast

fn test_let_statement() {
	input := 'let a = 3;
	let b = 4;
	let ab = 13;
	'
	p := parser.new_repl_parser(input)
	program := p.parse_top_lvl()

	if program.statements.len != 3 {
		eprintln('program.statement does not contain 3 statements, got = ${program.statements.len}')
		assert false
	}

	tests := ['a', 'b', 'ab']

	for i, tt in tests {
		let_stmt := program.statements[i] as ast.LetStatement
		if !let_statement(let_stmt, tt) {
			eprintln('test failed')
			assert false
		}
	}
}

fn let_statement(stmt ast.LetStatement, name string) bool {
		if stmt.name.value != name {
			eprintln('stmt.name.value not ${name} got ${stmt.name.value}')
			return false
		}
		if stmt.token_literal() != name {
			eprintln('stmt.name not ${name} got ${stmt.name}')
			return false
		}
		return true
}

fn test_return_statement() {
	input := 'return 3;
	return 13;
	return 24;
	'
	p := parser.new_repl_parser(input)
	program := p.parse_stmt()

	if program.statements.len != 3 {
		eprintln('program.statement does not contain 3 statements, got = ${program.statements.len}')
		assert false
	}

	for stmt in program.statements {
		return_stmt := stmt as ast.ReturnStatement
		if return_stmt.token_literal() != 'return'  {
			eprintln('ast.ReturnStatement doesn\'t `return`, got ${return_stmt.token_literal()} instead ')
			assert false
		}
	}
	assert true
}
