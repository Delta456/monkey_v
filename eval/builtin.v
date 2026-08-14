module eval

import object

fn builtin_len(args []object.Object) object.Object {
	if args.len != 1 {
		return new_error('wrong number of arguments. want=1, got=${args.len}')
	}

	arg := args[0]
	match arg {
		object.Str { return object.Object(object.Integer{
				value: i64(arg.value.len)
			}) }
		object.Array { return object.Object(object.Integer{
				value: i64(arg.elements.len)
			}) }
		else { return new_error('argument to `len` not supported, got ${arg.otype()}') }
	}
}

fn builtin_first(args []object.Object) object.Object {
	if args.len != 1 {
		return new_error('wrong number of arguments. want=1, got=${args.len}')
	}
	if args[0].otype() != 'Array' {
		return new_error('argument to `first` must be Array, got ${args[0].otype()}')
	}

	arr := args[0] as object.Array
	if arr.elements.len == 0 {
		return nil_value
	}
	return arr.elements[0]
}

fn builtin_last(args []object.Object) object.Object {
	if args.len != 1 {
		return new_error('wrong number of arguments. want=1, got=${args.len}')
	}
	if args[0].otype() != 'Array' {
		return new_error('argument to `last` must be Array, got ${args[0].otype()}')
	}

	arr := args[0] as object.Array
	if arr.elements.len == 0 {
		return nil_value
	}
	return arr.elements[arr.elements.len - 1]
}

fn builtin_rest(args []object.Object) object.Object {
	if args.len != 1 {
		return new_error('wrong number of arguments. want=1, got=${args.len}')
	}
	if args[0].otype() != 'Array' {
		return new_error('argument to `last` must be Array, got ${args[0].otype()}')
	}

	arr := args[0] as object.Array
	if arr.elements.len == 0 {
		return nil_value
	}

	return object.Object(object.Array{
		elements: arr.elements[1..].clone()
	})
}

fn builtin_push(args []object.Object) object.Object {
	if args.len != 2 {
		return new_error('wrong number of arguments. want=2, got=${args.len}')
	}
	if args[0].otype() != 'Array' {
		return new_error('first argument to `push` must be Array, got ${args[0].otype()}')
	}

	arr := args[0] as object.Array
	mut new_elems := arr.elements.clone()
	new_elems << args[1]
	return object.Object(object.Array{
		elements: new_elems
	})
}

fn builtin_puts(args []object.Object) object.Object {
	for arg in args {
		println(arg.inspect())
	}
	return nil_value
}

const builtins = {
	'len':   object.Builtin{
		func: builtin_len
	}
	'first': object.Builtin{
		func: builtin_first
	}
	'last':  object.Builtin{
		func: builtin_last
	}
	'rest':  object.Builtin{
		func: builtin_rest
	}
	'push':  object.Builtin{
		func: builtin_push
	}
	'puts':  object.Builtin{
		func: builtin_puts
	}
}
