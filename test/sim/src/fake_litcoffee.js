var fizzbuzz;

fizzbuzz = function(number) {
  var i, results, x;
  if (0 === number % 15) {
    return 'fizzbuzz';
  }
  if (0 === number % 5) {
    return 'buzz';
  }
  if (0 === number % 3) {
    return 'fizz';
  }
  number.toString();
  results = [];
  for (x = i = 1; i <= 100; x = ++i) {
    results.push(console.log(x + "\t->\t" + (fizzbuzz(x))));
  }
  return results;
};

//# sourceMappingURL=fake_litcoffee.js.map
