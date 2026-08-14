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

let reduce = fn(arr, initial, f) {
  let iter = fn(arr, result) {
    if (len(arr) == 0) {
      result
    } else {
      iter(rest(arr), f(result, first(arr)));
    }
  };

  iter(arr, initial);
};

let filter = fn(arr, f) {
  let iter = fn(arr, accumulated) {
    if (len(arr) == 0) {
      accumulated
    } else {
      if (f(first(arr))) {
        iter(rest(arr), push(accumulated, first(arr)));
      } else {
        iter(rest(arr), accumulated);
      }
    }
  };

  iter(arr, []);
};

let sum = fn(arr) {
  reduce(arr, 0, fn(result, el) { result + el });
};

let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
let evens = filter(numbers, fn(x) { x / 2 * 2 == x });
let squared = map(evens, fn(x) { x * x });

puts("evens:");
puts(evens);
puts("squared evens:");
puts(squared);
puts("sum of squared evens:");
sum(squared);
