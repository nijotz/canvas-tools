define () ->

  # This function takes a canvas element and wraps the getContext function with
  # a function that wraps the returned context object.  The new context object
  # will slightly modify coordinate arguments of draw functions to inject a 
  # slight error every frame to simulate a hand drawn sketch
  SketchCanvas = (canvas) ->

    # The functions to override and the arguments to modify
    overrides = {
      'arc': [0, 1, 2],
      'arcTo': [0, 1, 2, 3, 4],
      'bezierCurveTo': [0, 1, 2, 3, 4, 5],
      'lineTo': [0, 1],
      'moveTo': [0, 1],
      'rect': [0, 1, 2, 3],
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

      wrapDrawFunction = (func, arg_nums, width, height) =>
        return () ->
          for arg_num in arg_nums
            #TODO: listing argument numbers to modify AND whether they are x or
            # y means that the margin_of_error can scale properly
            arguments[arg_num] += width * margin_of_error * (-0.5 + Math.random())

          newcontext['orig_' + func].apply(this, arguments)

      for func, arg_nums of overrides
        if (newcontext['orig_' + func] == undefined)
          newcontext['orig_' + func] = newcontext[func]

        newcontext[func] = wrapDrawFunction(func, arg_nums, width, height)

      return newcontext

    return canvas

  return SketchCanvas
