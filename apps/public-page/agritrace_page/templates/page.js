// Tap-to-enlarge for evidence photos and print expansion, inlined by batch.html.j2 (W01, W03;
// plan §13 E2; budget < 4 KB). Without JS the photo link opens the medium WebP; with JS the thumbnail
// swaps to it in place. Section expand needs no JS: timelines are native <details>.
document.addEventListener("click", function (e) {
  var a = e.target.closest && e.target.closest("a.ph");
  if (!a) return;
  e.preventDefault();
  var s = a.querySelector("source");
  if (s && !a.dataset.big) { s.srcset = a.href; a.dataset.big = "1"; }
  a.classList.toggle("big");
});
// Printing opens every timeline so the paper copy is complete; print CSS keeps one photo per event.
addEventListener("beforeprint", function () {
  document.querySelectorAll("details").forEach(function (d) { d.open = true; });
});
