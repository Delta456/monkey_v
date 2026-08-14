let unless = macro(condition, consequence, alternative) {
  quote(
    if (!(unquote(condition))) {
      unquote(consequence);
    } else {
      unquote(alternative);
    }
  );
};

unless(10 > 5, puts("not greater"), puts("greater"));
