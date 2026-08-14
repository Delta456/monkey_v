# Monkey Interpreter in V

![CI](https://github.com/Delta456/monkey_v/workflows/CI/badge.svg?branch=master)

Implementation of the [Monkey Programming Language](https://monkeylang.org/) in [V](https://vlang.io/) Programming Language, following [Writing An Interpreter In Go](https://interpreterbook.com/) book.

It includes the full language: integers, floats, booleans, strings, arrays, hashes,
first-class and higher-order functions, closures, a builtin function library
(`len`, `first`, `last`, `rest`, `push`, `puts`), and the book's `quote`/`unquote`
macro system.

## Installation

Requires the [V compiler](https://github.com/vlang/v).

```sh
git clone https://github.com/Delta456/monkey_v
cd monkey_v
v build .
```

## Usage

Run a Monkey script:

```sh
v run main.v examples/fibonacci.monkey
```

Or start the REPL (no arguments):

```sh
v run main.v
```

## Syntax

```js
// integers, floats, booleans, strings
let age = 30;
let price = 9.99;
let name = "Monkey";
let active = true;

// arrays and hashes
let numbers = [1, 2, 3, 4];
let person = {"name": "Alice", "age": 30};
numbers[0];       // 1
person["name"];   // "Alice"

// first-class functions and closures
let newAdder = fn(x) {
  fn(y) { x + y };
};
let addTwo = newAdder(2);
addTwo(3); // 5

// recursion
let fibonacci = fn(x) {
  if (x < 2) {
    x
  } else {
    fibonacci(x - 1) + fibonacci(x - 2)
  }
};

// builtins: len, first, last, rest, push, puts
let map = fn(arr, f) {
  let iter = fn(arr, accumulated) {
    if (len(arr) == 0) {
      accumulated
    } else {
      iter(rest(arr), push(accumulated, f(first(arr))));
    }
  };
  iter(arr, []);
};
map(numbers, fn(x) { x * 2 }); // [2, 4, 6, 8]

// quote/unquote macros
let unless = macro(condition, consequence, alternative) {
  quote(
    if (!(unquote(condition))) {
      unquote(consequence);
    } else {
      unquote(alternative);
    }
  );
};
unless(10 > 5, puts("not greater"), puts("greater")); // "greater"
```

## Examples

More complete programs live in [`examples/`](examples):

| Script                           | Demonstrates                                     |
|----------------------------------|--------------------------------------------------|
| `fibonacci.monkey`               | Recursion                                        |
| `closures_and_arrays.monkey`     | Closures, arrays, `map` via builtins             |
| `higher_order_functions.monkey`  | `map`/`reduce`/`filter` built from scratch       |
| `hashes_and_strings.monkey`      | Hash literals/indexing, string concatenation     |
| `quicksort.monkey`               | Recursive sorting, array filtering/concatenation |
| `error_handling.monkey`          | Early returns and runtime error objects          |
| `macros.monkey`                  | The `quote`/`unquote` macro system               |

## Testing

```sh
v test .
```

## Project layout

| Module    | Description                                                |
|-----------|----------------------------------------------------------- |
| `token`   | Token types                                                |
| `lexer`   | Hand-written lexer                                         |
| `ast`     | AST node types (V sum types) and the `modify` tree-walker  |
| `parser`  | Pratt parser                                               |
| `object`  | Runtime object system and `Environment`                    |
| `eval`    | Tree-walking evaluator, builtins, and the macro system     |
| `repl`    | Interactive REPL                                           |
| `examples`| Sample `.monkey` scripts                                   |

## License

Licensed under [MIT](LICENSE.md).
