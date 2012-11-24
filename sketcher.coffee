define ['cs!canvas-tools/world'], (World) ->
  # TODO: circles are never draw perfectly round by hand.  Transform
  # and/or rotate.

  # TODO: Keep the last few strokes from every objects and fade them out

  # TODO: change lineTo's to beziers

  # This function takes a canvas element and wraps the getContext function with
  # a function that wraps the returned context object.  The new context object
  # will slightly modify coordinate arguments of draw functions to inject a 
  # slight error every frame to simulate a hand drawn sketch.  Also, all fills
  # are changed to strokes


  class SketcherContext extends CanvasRenderingContext2D
    constructor: () ->
      # The max amount that x/y coords will be offset is based on a percentage of
      # the canvas width/height
      @marginOfError = 0.0075

      # change fills to strokes
      #for func of this
      #  if func.indexOf('fill') == 0 && func != 'fillRect' #TODO: don't need != fillRect?
      #    if this['orig_' + func] == undefined
      #      this['orig_' + func] = this[func]
      #    this[func] = this[func.replace('fill', 'stroke')]
      #this['fill'] = this['stroke']
      #this['fillStyle'] = this['strokeStyle']

    arc: () ->
      args = @nudge(arguments)
      super args...

    lineTo: () ->
      args = @nudge(arguments)
      super args...

    arcTo: () ->
      args = @nudge(arguments)
      super args...

    fill: () ->
      @fillStyle = 'rgba(255,255,255,0.9)'
      super
      @stroke()

    bezierCurveTo: () ->
      args = @nudge(arguments)
      super args...

    nudge: (args) ->
      nudged_args = []

      for arg, i in args
        base = @canvas.width
        if i % 2
          base = @canvas.height
        nudged_args[i] = arg + base * @marginOfError * (-0.5 + Math.random())

      return nudged_args

  class SketcherWorld extends World.World
    constructor: (canvas) ->
      super(canvas)

      @sketches = []

      # Number of past sketched lines to keep on the screen
      @num_sketches = 4
      @cur_sketch = 0

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
        context.__proto__ = SketcherContext.prototype
        context.__proto__.constructor()
        obj.draw(context)

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

  return SketcherWorld
