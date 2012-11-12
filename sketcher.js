define(function() {

return function(canvas) {
  canvas.orig_getContext = canvas.getContext;
  canvas.getContext = function(twod) {
    newcontext = this.orig_getContext('2d');
    width = this.width;
    height = this.height;
    overrides = [
      ['arc', [0, 1, 2]],
      ['arcTo', [0, 1, 2, 3, 4]],
      ['bezierCurveTo', [0, 1, 2, 3, 4, 5]],
      ['lineTo', [0, 1]],
      ['rect', [0, 1, 2, 3]],
    ];

    function modifyCanvasFunc(func, args, width, height) {
      return function() {
        for (i in args) {
          arguments[args[i]] += width * (-0.5 + Math.random()) / 25;
        }
        newcontext['orig_' + func].apply(this, arguments)
      }
    }

    for (j in overrides) {
      var func = overrides[j][0];
      var args = overrides[j][1];
      if (newcontext['orig_' + func] == undefined) {
        newcontext['orig_' + func] = newcontext[func];
      }
      newcontext[func] = modifyCanvasFunc(func, args, width, height);
    }

    return newcontext;
  }

  return canvas
}

});
