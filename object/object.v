module object

import ast

// Object represents an object of the Monkey language.
pub type Object = Array
	| Boolean
	| Builtin
	| ErrorObj
	| Float
	| Function
	| Hash
	| Integer
	| Macro
	| Nil
	| Quote
	| ReturnValue
	| Str

// Integer represents an integer.
pub struct Integer {
pub:
	value i64
}

pub fn (i Integer) type_name() string {
	return 'Integer'
}

pub fn (i Integer) inspect() string {
	return '${i.value}'
}

pub fn (i Integer) hash_key() string {
	return 'Integer:${i.value}'
}

// Float represents a floating point number.
pub struct Float {
pub:
	value f64
}

pub fn (f Float) type_name() string {
	return 'Float'
}

pub fn (f Float) inspect() string {
	return '${f.value}'
}

pub fn (f Float) hash_key() string {
	return 'Float:${f.value}'
}

// Boolean represents a boolean.
pub struct Boolean {
pub:
	value bool
}

pub fn (b Boolean) type_name() string {
	return 'Boolean'
}

pub fn (b Boolean) inspect() string {
	return '${b.value}'
}

pub fn (b Boolean) hash_key() string {
	return 'Boolean:${b.value}'
}

// Nil represents the absence of any value.
pub struct Nil {}

pub fn (n Nil) type_name() string {
	return 'Nil'
}

pub fn (n Nil) inspect() string {
	return 'nil'
}

// ReturnValue wraps a value produced by a `return` statement.
pub struct ReturnValue {
pub:
	value Object
}

pub fn (rv ReturnValue) type_name() string {
	return 'ReturnValue'
}

pub fn (rv ReturnValue) inspect() string {
	return rv.value.inspect()
}

// ErrorObj represents an evaluation error.
pub struct ErrorObj {
pub:
	message string
}

pub fn (e ErrorObj) type_name() string {
	return 'Error'
}

pub fn (e ErrorObj) inspect() string {
	return 'Error: ${e.message}'
}

// Function represents a function.
pub struct Function {
pub:
	parameters []ast.Ident
	body       ast.BlockStatement
	env        &Environment
}

pub fn (f Function) type_name() string {
	return 'Function'
}

pub fn (f Function) inspect() string {
	params := f.parameters.map(it.str()).join(', ')
	return 'fn(${params}) {\n${f.body.str()}\n}'
}

// Str represents a string.
pub struct Str {
pub:
	value string
}

pub fn (s Str) type_name() string {
	return 'String'
}

pub fn (s Str) inspect() string {
	return s.value
}

pub fn (s Str) hash_key() string {
	return 'String:${s.value}'
}

// BuiltinFunction is the signature of builtin functions.
pub type BuiltinFunction = fn (args []Object) Object

// Builtin represents a builtin function.
pub struct Builtin {
pub:
	func BuiltinFunction @[required]
}

pub fn (b Builtin) type_name() string {
	return 'Builtin'
}

pub fn (b Builtin) inspect() string {
	return 'builtin function'
}

// Array represents an array.
pub struct Array {
pub:
	elements []Object
}

pub fn (a Array) type_name() string {
	return 'Array'
}

pub fn (a Array) inspect() string {
	elements := a.elements.map(it.inspect()).join(', ')
	return '[${elements}]'
}

// HashPair represents a key-value pair in a hash.
pub struct HashPair {
pub:
	key   Object
	value Object
}

// Hash represents a hash.
pub struct Hash {
pub:
	pairs map[string]HashPair
}

pub fn (h Hash) type_name() string {
	return 'Hash'
}

pub fn (h Hash) inspect() string {
	mut pairs := []string{cap: h.pairs.len}
	for _, pair in h.pairs {
		pairs << '${pair.key.inspect()}: ${pair.value.inspect()}'
	}
	return '{${pairs.join(', ')}}'
}

// hash_key_of returns the hash key of `obj` if it can be used as a hash key.
pub fn hash_key_of(obj Object) ?string {
	return match obj {
		Integer { obj.hash_key() }
		Float { obj.hash_key() }
		Boolean { obj.hash_key() }
		Str { obj.hash_key() }
		else { none }
	}
}

// Quote represents a quote, i.e. an unevaluated expression, used for macros.
pub struct Quote {
pub:
	node ast.Node
}

pub fn (q Quote) type_name() string {
	return 'Quote'
}

pub fn (q Quote) inspect() string {
	return 'Quote(${q.node.str()})'
}

// Macro represents a macro.
pub struct Macro {
pub:
	parameters []ast.Ident
	body       ast.BlockStatement
	env        &Environment
}

pub fn (m Macro) type_name() string {
	return 'Macro'
}

pub fn (m Macro) inspect() string {
	params := m.parameters.map(it.str()).join(', ')
	return 'macro(${params}) {\n${m.body.str()}\n}'
}

// Object dispatch

pub fn (o Object) otype() string {
	return match o {
		Integer { o.type_name() }
		Float { o.type_name() }
		Boolean { o.type_name() }
		Nil { o.type_name() }
		ReturnValue { o.type_name() }
		ErrorObj { o.type_name() }
		Function { o.type_name() }
		Str { o.type_name() }
		Builtin { o.type_name() }
		Array { o.type_name() }
		Hash { o.type_name() }
		Quote { o.type_name() }
		Macro { o.type_name() }
	}
}

pub fn (o Object) inspect() string {
	return match o {
		Integer { o.inspect() }
		Float { o.inspect() }
		Boolean { o.inspect() }
		Nil { o.inspect() }
		ReturnValue { o.inspect() }
		ErrorObj { o.inspect() }
		Function { o.inspect() }
		Str { o.inspect() }
		Builtin { o.inspect() }
		Array { o.inspect() }
		Hash { o.inspect() }
		Quote { o.inspect() }
		Macro { o.inspect() }
	}
}
