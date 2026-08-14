let safe_div = fn(a, b) {
  if (b == 0) {
    return "error: division by zero";
  }

  a / b;
};

puts("10 / 2:");
puts(safe_div(10, 2));

puts("10 / 0:");
puts(safe_div(10, 0));

let bad_types = fn() {
  5 + true;
};

bad_types();
