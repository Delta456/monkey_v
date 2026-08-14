module object

fn test_string_hash_key() {
	hello1 := Str{
		value: 'Hello World'
	}
	hello2 := Str{
		value: 'Hello World'
	}
	diff1 := Str{
		value: 'My name is johnny'
	}
	diff2 := Str{
		value: 'My name is johnny'
	}

	assert hello1.hash_key() == hello2.hash_key()
	assert diff1.hash_key() == diff2.hash_key()
	assert hello1.hash_key() != diff1.hash_key()
}

fn test_boolean_hash_key() {
	true1 := Boolean{
		value: true
	}
	true2 := Boolean{
		value: true
	}
	false1 := Boolean{
		value: false
	}
	false2 := Boolean{
		value: false
	}

	assert true1.hash_key() == true2.hash_key()
	assert false1.hash_key() == false2.hash_key()
	assert true1.hash_key() != false1.hash_key()
}

fn test_integer_hash_key() {
	one1 := Integer{
		value: 1
	}
	one2 := Integer{
		value: 1
	}
	two1 := Integer{
		value: 2
	}
	two2 := Integer{
		value: 2
	}

	assert one1.hash_key() == one2.hash_key()
	assert two1.hash_key() == two2.hash_key()
	assert one1.hash_key() != two1.hash_key()
}

fn test_environment() {
	mut env := new_environment()
	env.set('x', Object(Integer{
		value: 5
	}))

	x := env.get('x') or { panic('expected x to be set') }
	assert (x as Integer).value == 5

	mut inner := new_enclosed_environment(env)
	inner.set('y', Object(Integer{
		value: 10
	}))

	y := inner.get('y') or { panic('expected y to be set') }
	assert (y as Integer).value == 10

	// closures can see the outer scope
	x2 := inner.get('x') or { panic('expected x to be visible from inner scope') }
	assert (x2 as Integer).value == 5

	if _ := env.get('y') {
		assert false
	}
}
