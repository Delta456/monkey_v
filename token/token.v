module token

// Type is a token type.
pub type Type = string

pub const illegal = Type('ILLEGAL')
pub const eof = Type('EOF')

pub const ident = Type('IDENT')
pub const int_tok = Type('INT')
pub const float_tok = Type('FLOAT')
pub const str = Type('STRING')

pub const bang = Type('!')
pub const assign = Type('=')
pub const plus = Type('+')
pub const minus = Type('-')
pub const asterisk = Type('*')
pub const slash = Type('/')
pub const lt = Type('<')
pub const gt = Type('>')
pub const eq = Type('==')
pub const not_eq = Type('!=')

pub const comma = Type(',')
pub const semicolon = Type(';')
pub const colon = Type(':')

pub const lparen = Type('(')
pub const rparen = Type(')')
pub const lbrace = Type('{')
pub const rbrace = Type('}')
pub const lbracket = Type('[')
pub const rbracket = Type(']')

pub const key_function = Type('FUNCTION')
pub const key_let = Type('LET')
pub const key_true = Type('TRUE')
pub const key_false = Type('FALSE')
pub const key_if = Type('IF')
pub const key_else = Type('ELSE')
pub const key_return = Type('RETURN')
pub const key_macro = Type('MACRO')

// Token represents a token which has a token type and literal.
pub struct Token {
pub:
	typ     Type
	literal string
}

// lookup_ident checks the language keywords to see whether the given identifier is a keyword.
// If it is, it returns the keyword's Type constant. If it isn't, it just returns `ident`.
pub fn lookup_ident(ident_ string) Type {
	return match ident_ {
		'fn' { key_function }
		'let' { key_let }
		'true' { key_true }
		'false' { key_false }
		'if' { key_if }
		'else' { key_else }
		'return' { key_return }
		'macro' { key_macro }
		else { ident }
	}
}
