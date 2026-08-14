let newAdder = fn(x) {
  fn(y) { x + y };
};

let addTwo = newAdder(2);

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

let numbers = [1, 2, 3, 4];
let doubled = map(numbers, fn(x) { x * 2 });

puts("addTwo(3):");
puts(addTwo(3));
puts("doubled numbers:");
doubled;
