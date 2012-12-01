define ['cs!canvas-tools/world'], (World) ->

  # TODO: It would look better if lineTo and bezierCurveTo ended and
  # started at a new point somewhat close to it, simulated an artist
  # picking up their drawing utensil between lines. However, this would
  # require completely redoing how SketcherContext functions. Rather than
  # simply nudge coordinates as they come in and replace fillStyles with
  # stroke followed by a white fill, it would have to save up all the
  # instructions as they come in.  Then when a fill happens, apply all the
  # instructions twice.  Once for the white fill, once for the seperate lines.

  class SketcherContext extends CanvasRenderingContext2D
    constructor: () ->
      # The max amount that x/y coords will be offset is based on a percentage of
      # the canvas width/height
      @marginOfError = 0.004

      # change fills to strokes
      #for func of this
      #  if func.indexOf('fill') == 0 && func != 'fillRect' #TODO: don't need != fillRect?
      #    if this['orig_' + func] == undefined
      #      this['orig_' + func] = this[func]
      #    this[func] = this[func.replace('fill', 'stroke')]
      #this['fill'] = this['stroke']
      #this['fillStyle'] = this['strokeStyle']

      @curX = 0
      @curY = 0

      @color = false

    arc: (x, y) ->
      args = arguments

      # nudge only the coordiantes
      coords = [args[0], args[1]]
      coords = @nudge(coords)

      @save()

      # Do the move now rather than pass to super() so rotate()
      # rotates arond the center of the arc
      args[0] = 0
      args[1] = 0
      @translate(coords[0], coords[1])

      # no one draws a perfect circle
      @rotate(Math.random() * Math.PI * 2)
      @scale(@_nudge(1, 1, 0.1), @_nudge(1, 1, 0.1))

      super args...

      @restore()

    moveTo: (x, y) ->
      @curX = x
      @curY = y
      super(x, y)

    lineTo: (x, y) ->
      half = []
      half[0] = (@curX + x) / 2
      half[1] = (@curY + y) / 2
      half = @nudge(half, @marginOfError * 2)

      @curX = x
      @curY = y

      args = [half[0], half[1], half[0], half[1], x, y]
      @bezierCurveTo args...

    translate: () ->
      args = @nudge(arguments)
      super args...

    fill: () ->
      if !@color
        @fillStyle = 'rgba(255,255,255,0.9)'
      super
      @stroke()

    bezierCurveTo: () ->
      @curX = arguments[4]
      @curY = arguments[5]

      args = @nudge(arguments)
      super args...

    nudge: (args, moe) ->

      if !moe
        moe = @marginOfError

      nudged_args = []
      for arg, i in args

        # Usually even numbered coordinates are y (height-based)
        base = @canvas.width
        if i % 2
          base = @canvas.height

        # randomly nudge the coordinate argument
        nudged_args[i] = @_nudge(arg, base, moe)

      return nudged_args

    _nudge: (val, base, moe) ->
      return val + base * moe * (-0.5 + Math.random())

  class SketcherWorld extends World.World
    constructor: (canvas) ->
      @sketches = []

      # Number of past sketched lines to keep on the screen
      @num_sketches = 4
      @cur_sketch = 0

      @fillColor = false

      super(canvas)

    eventResize: =>
      @canvas.width = Math.floor(document.body.clientWidth / @scale)
      @canvas.height = Math.floor(document.body.clientHeight / @scale)
      @setWidth( @canvas.width )
      @setHeight( @canvas.height )

      # get all the sketches too
      for object_sketches in @sketches
        for sketch in object_sketches
          sketch.width = @width
          sketch.height = @height

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
      @context.save()
      @context.fillStyle = "rgb(255,255,255)"
      @context.fillRect(0, 0, @width, @height)
      @context.restore()

      # sketch every object
      for obj, i in @objects

        # modify the current sketch in the cycle
        # TODO. changing proto every frame..
        sketches = @sketches[i]
        context = sketches[@cur_sketch].getContext('2d')
        context.clearRect(0, 0, @width, @height)
        context.__proto__ = SketcherContext.prototype
        context.__proto__.constructor()
        context.color = @fillColor
        obj.draw(context)

        # Draw every num_sketches sketch of this object
        @context.save()

        @context.globalAlpha = 1
        sketch_num = @cur_sketch
        for i in [0..@num_sketches]
          # alpha decreases as we iterate through the sketches
          @context.globalAlpha = 1 / ((i + 1) * 2)
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
