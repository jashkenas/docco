var jSLink_els = document.getElementsByClassName("source")
  , jSources = []
  , jF_el = document.getElementById("jump_filter")
  , jFC_el = document.getElementById("jump_filter_clear")
  , jS_el = document.getElementById("jump_sources")
  , jR_el = document.getElementById("jump_results");

function makefuzzy( txt ) {
  return new RegExp(txt.split("").map(function( c ) {
    return "\\/?!,.:=-+*^$[]()".indexOf(c) > -1 ? "\\\\" + c : c;
  }).join(".*"));
}

function toggleJump( txt ) {
  jS_el.style.display = txt ? "none" : "block";
  jR_el.style.display = txt ? "block" : "none";
  return txt;
}

for (var i=0, j=jSLink_els.length; i<j; i++) {
  jSources.push(jSLink_els[i].textContent.trim().toLowerCase());
}

jF_el.addEventListener("keyup", function() {
  var txt = this.value.trim().toLowerCase()
    , fuzz = makefuzzy(txt)
    , srcWeights = [];
  
  if (!toggleJump(txt)) return true;
  
  for (var i=0, j=jSources.length; i<j; i++) {
    switch (jSources[i].indexOf(txt)) {
      case -1:
        if (fuzz.test(jSources[i]))
          srcWeights.push({ weight: 3, idx: i });
        break;
      case 0:
        srcWeights.push({ weight: 1, idx: i });
        break;
      default:
        srcWeights.push({ weight: 2, idx: i });
    }
  }
  
  jR_el.innerHTML = "";
  srcWeights.sort(function( a, b ) {
    return a.weight - b.weight;
  }).forEach(function( src ) {
    jR_el.appendChild(jSLink_els[src.idx].cloneNode(true));
  });
});
jFC_el.addEventListener("click", function() { toggleJump(jF_el.value = ""); });