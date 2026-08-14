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

let concat = fn(a, b) {
  let iter = fn(arr, accumulated) {
    if (len(arr) == 0) {
      accumulated
    } else {
      iter(rest(arr), push(accumulated, first(arr)));
    }
  };

  iter(b, iter(a, []));
};

let quicksort = fn(arr) {
  if (len(arr) < 2) {
    arr
  } else {
    let pivot = first(arr);
    let others = rest(arr);

    let less = filter(others, fn(x) { x < pivot });
    let more = filter(others, fn(x) { !(x < pivot) });

    concat(concat(quicksort(less), [pivot]), quicksort(more));
  }
};

quicksort([9, 3, 7, 1, 8, 2, 5, 4, 6]);
