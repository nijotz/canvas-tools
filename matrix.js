define(["js/canvas-tools/contrib/sylvester.js"], function() {

Matrix.prototype.convolute = function(conv, multiplier) {

  multiplier = (multiplier == undefined) ? 1 : multiplier;

  var matdim = this.dimensions();
  var condim; 
  var offset;
  var callback = conv;
  var newval = 0;

  if (conv instanceof Matrix) { 
    condim = conv.dimensions();
    offset = -Math.floor(condim.rows / 2);
    callback = false;

    if (condim.rows % 2 === 0 || condim.cols % 2 === 0) {
      throw 'Convolution matrices must have odd dimensions'
    }

    if (condim.rows != condim.cols) {
      throw 'Convolution matrices must be square'
    }
  } else if (! conv instanceof Function) {
    throw 'conv must be a matrix or a callback that returns a matrix'
  }

  var copy = this.dup();

  //Matrix.e uses 1-based indexing
  for (var maty=1; maty < matdim.rows + 1; maty++) {
    for (var matx=1; matx < matdim.cols + 1; matx++) {

      if (callback) {
        conv = callback(matx, maty, copy.e(matx, maty));
        condim = conv.dimensions();
        offset = -Math.floor(condim.rows / 2);
      }
      newval = 0;
      for (var cony=0; cony<condim.rows; cony++) {
        for (var conx=0; conx<condim.cols; conx++) {
      
          //Matrix.e is used because it will return null if addressing an 
          //element that doesn't exist, so I don't have to check
          var val = conv.elements[conx][cony];
          if (!val) {break}
          newval += val * copy.e(matx + conx - offset, maty + cony - offset);
        }
      }

      copy.elements[matx - 1][maty - 1] = newval * multiplier;
    }
  }

  this.elements = copy.elements;
}

return Matrix;

});
