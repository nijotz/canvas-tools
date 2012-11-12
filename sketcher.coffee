define () ->
  # TODO: world uses fillRect to clear frames. So there's an exception to the
  # fill/stroke replacement code below. This needs to be turned into a world
  # subclass that uses the normal context but provides a modified context to
  # objects.

  # TODO: circles are never draw perfectly round by hand.  Transform
  # and/or rotate.

  # TODO: Keep the last few strokes from every objects and fade them out

  # TODO: change lineTo's to beziers

  # This function takes a canvas element and wraps the getContext function with
  # a function that wraps the returned context object.  The new context object
  # will slightly modify coordinate arguments of draw functions to inject a 
  # slight error every frame to simulate a hand drawn sketch.  Also, all fills
  # are changed to strokes
  SketchCanvas = (canvas) ->

    # The functions to override and the arguments to modify
    overrides = {
      'arc': ['x', 'y', 'r'],
      'arcTo': ['x', 'y', 'x', 'y', 'r'],
      'bezierCurveTo': ['x', 'y', 'x', 'y', 'x', 'y'],
      'lineTo': ['x', 'y'],
      'moveTo': ['x', 'y'],
      'rect': ['x', 'y', 'x', 'y'],
    }

    # The max amount that x/y coords will be offset is based on a percentage of
    # the canvas width/height
    margin_of_error = 0.02

    canvas.orig_getContext = canvas.getContext

    # This assumes that getContext will always be 2d
    canvas.getContext = (twod) ->
      newcontext = this.orig_getContext('2d')
      width = this.width
      height = this.height

      # margin of error wrapper
      wrapDrawFunction = (func, args, width, height) =>
        return () ->
          for arg, i in args
            #TODO: 'r' should be based on x and y
            if arg == 'x' || arg == 'r'
              base = width
            else
              base = height
            arguments[i] += base * margin_of_error * (-0.5 + Math.random())

          newcontext['orig_' + func].apply(this, arguments)

      # wrap draw functions with margin of error function
      for func, arg_nums of overrides
        if newcontext['orig_' + func] == undefined
          newcontext['orig_' + func] = newcontext[func]
        newcontext[func] = wrapDrawFunction(func, arg_nums, width, height)

      # Change fills to strokes
      for func of newcontext
        if func.indexOf('fill') == 0 && func != 'fillRect'
          if newcontext['orig_' + func] == undefined
            newcontext['orig_' + func] = newcontext[func]
          newcontext[func] = newcontext[func.replace('fill', 'stroke')]

      return newcontext

    return canvas

  return SketchCanvas
