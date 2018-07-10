var typeIsArray;

typeIsArray = Array.isArray || function(value) {
  return {}.toString.call(value) === '[object Array]';
};

module.exports = typeIsArray;

//# sourceMappingURL=typeIsArray.js.map
