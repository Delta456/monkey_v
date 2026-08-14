module object

// Environment associates values with variable names.
@[heap]
pub struct Environment {
mut:
	store map[string]Object
	outer ?&Environment
}

// new_environment returns a new, empty Environment.
pub fn new_environment() &Environment {
	return &Environment{
		store: map[string]Object{}
	}
}

// new_enclosed_environment returns a new Environment enclosed by `outer`.
pub fn new_enclosed_environment(outer &Environment) &Environment {
	mut env := new_environment()
	env.outer = outer
	return env
}

// get retrieves the value of a variable named by `name`.
pub fn (e &Environment) get(name string) ?Object {
	if val := e.store[name] {
		return val
	}
	if outer := e.outer {
		return outer.get(name)
	}
	return none
}

// set sets the value of a variable named by `name` and returns it.
pub fn (mut e Environment) set(name string, val Object) Object {
	e.store[name] = val
	return val
}
