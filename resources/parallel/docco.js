var sourceElements = document.getElementsByClassName("source"),
  sourceNames = [],
  filterInput = document.getElementById("jump_filter"),
  sourcesWrapper = document.getElementById("jump_sources"),
  resultsWrapper = document.getElementById("jump_results");

for (var i=0, j=sourceElements.length; i<j; i++) {
  sourceNames.push(sourceElements[i].textContent.trim().toLowerCase());
}

function makefuzzy(txt) {
  return new RegExp(txt.split("").map(function( c ) {
    return "\\/?!,.:=-+*^$[]()".indexOf(c) > -1 ? "\\\\" + c : c;
  }).join(".*"));
}

function toggleJump(txt) {
  sourcesWrapper.style.display = txt ? "none" : "block";
  resultsWrapper.style.display = txt ? "block" : "none";
  return txt;
}

filterInput.addEventListener("keyup", function() {
  var txt = this.value.trim().toLowerCase(),
    fuzz = makefuzzy(txt),
    srcWeights = [];

  if (!toggleJump(txt)) return true;

  for (var i=0, j=sourceNames.length; i<j; i++) {
    switch (sourceNames[i].indexOf(txt)) {
      case -1:
        if (fuzz.test(sourceNames[i]))
          srcWeights.push({ weight: 3, idx: i });
        break;
      case 0:
        srcWeights.push({ weight: 1, idx: i });
        break;
      default:
        srcWeights.push({ weight: 2, idx: i });
    }
  }

  resultsWrapper.innerHTML = "";
  srcWeights.sort(function( a, b ) {
    return a.weight - b.weight;
  }).forEach(function( src ) {
    resultsWrapper.appendChild(sourceElements[src.idx].cloneNode(true));
  });
});
