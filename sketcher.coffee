define ['cs!canvas-tools/world'], (World) ->
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

  class SketchedWorld extends World.World
    constructor: (canvas) ->
      super(canvas)

      @sketches = []

      # Number of past sketched lines to keep on the screen
      @num_sketches = 4
      @cur_sketch = 0

      # The functions to override and the arguments to modify
      @overrides = {
        'arc': ['x', 'y', 'r'],
        'arcTo': ['x', 'y', 'x', 'y', 'r'],
        'bezierCurveTo': ['x', 'y', 'x', 'y', 'x', 'y'],
        'lineTo': ['x', 'y'],
        'moveTo': ['x', 'y'],
        'rect': ['x', 'y', 'x', 'y'],
      }

      # The max amount that x/y coords will be offset is based on a percentage of
      # the canvas width/height
      @marginOfError = 0.0075

      # modify context draw calls to be sketch-like (introduce a margin of error)
      @modifyContext = (context) =>
        wrapDrawFunction = (context, func, args, width, height) =>
          return () =>
            for arg, i in args
              #TODO: 'r' should be based on x and y
              if arg == 'x' || arg == 'r'
                base = width
              else
                base = height
              arguments[i] += base * @marginOfError * (-0.5 + Math.random())
            context['orig_' + func].apply(context, arguments)

        # wrap draw functions with margin of error function
        for func, args of @overrides
          if context['orig_' + func] == undefined
            context['orig_' + func] = context[func]
          context[func] = wrapDrawFunction(context, func, args, @width, @height)

        # change fills to strokes
        for func of context
          if func.indexOf('fill') == 0 && func != 'fillRect'
            if context['orig_' + func] == undefined
              context['orig_' + func] = context[func]
            context[func] = context[func.replace('fill', 'stroke')]

        return context

    addObject: (object) ->
      sketches = []
      for i in [0..@num_sketches]
        canvas = document.createElement('canvas')
        canvas.width = @width
        canvas.height = @height
        sketches.push(canvas)
      @objects.push(object)
      @sketches.push(sketches)

    draw: ->

      # clear the canvas
      @color = "rgb(255,255,255)"
      @context.save()
      @context.fillStyle = @color
      @context.fillRect(0, 0, @width, @height)
      @context.restore()

      # sketch every object
      for obj, i in @objects

        # modify the current sketch in the cycle
        sketches = @sketches[i]
        context = sketches[@cur_sketch].getContext('2d')
        context.clearRect(0, 0, @width, @height)
        sketcher = @modifyContext(context)
        obj.draw(sketcher)

        # Draw every num_sketches sketch of this object
        @context.save()

        @context.globalAlpha = 1
        sketch_num = @cur_sketch
        for i in [0..@num_sketches]
          # alpha decreases as we iterate through the sketches
          @context.globalAlpha = 1 / (i + 1)
          sketch = sketches[sketch_num]
          @context.drawImage(sketch, 0, 0)

          sketch_num += 1
          if sketch_num >= @num_sketches
            sketch_num = 0

        @context.restore()

      # keep track of which sketch we modify on the next draw
      @cur_sketch += 1
      if @cur_sketch >= @num_sketches
        @cur_sketch = 0

      if @displayFPS
        @drawFPS()

  return SketchedWorld
