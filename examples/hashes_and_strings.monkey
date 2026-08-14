let people = [
  {"name": "Alice", "age": 30},
  {"name": "Bob", "age": 25}
];

let names = fn(arr) {
  let iter = fn(arr, accumulated) {
    if (len(arr) == 0) {
      accumulated
    } else {
      iter(rest(arr), push(accumulated, first(arr)["name"]));
    }
  };

  iter(arr, []);
};

puts("names:");
puts(names(people));

let counts = {"a": 1, "b": 2, "c": 3};
puts("count of b:");
puts(counts["b"]);

let greeting = "Hello" + ", " + "Monkey!";
puts(greeting);

len(greeting);
