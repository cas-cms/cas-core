/**
 * Guess what, Javascript doesn't have .sort() by integer out-of-the-box.
 */
function sortNumber(a, b) {
  return parseInt(a) - parseInt(b);
}

function sortFilenames(a, b) {
  var numberRegex = /(\d+)/g;
  /**
   * Both values have numbers
   */
  if (a.toString().match(numberRegex) && b.toString().match(numberRegex)) {
    return (Number(a.match(numberRegex)[0]) - Number(b.match(numberRegex)[0]));
  } else {
    return a.localeCompare(b);
  }
}
