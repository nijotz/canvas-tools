define ['jquery'], ($) ->

  class BaseEntity
    constructor: (@world, @width = 0, @height = 0) ->
      @canvas = document.createElement('canvas')
      @resize(@width, @height)
      @updaters = []
      @redraw = true
      @x = 0
      @y = 0

    resize: (@width = 0, @height = 0) ->
      if !@width:
        @width = @world.width
      if !@height:
        @height = @world.height

      @canvas.width = @width
      @canvas.height= @height

    addUpdater: (callback, sequence = 0) ->
      callback.sequence = sequence
      @updaters.push(callback)
      @updaters.sort((a,b) -> return a.sequence - b.sequence)

    draw: (context, interp) ->
      context.drawImage(@canvas, @x, @y)

    update: () ->
      for updater in @updaters
        updater.call(this)


  class World
    constructor: (canvas) ->
      @width = 0
      @height = 0
      @scale = 1 # Ratio of screen pixels to canvas pixels
      @frametimes = []
      @ticks = 30
      @tick_time = 1000 / @ticks
      @max_frameskip = 5 # how many update calls to perform without a draw call
      @objects = []
      @color = "rgb(0,0,0)"
      @displayFPS = false
      @setCanvas(canvas)
      window.addEventListener('resize', @eventResize, false)

    setCanvas: (@canvas) ->
      @context = @canvas.getContext('2d')
      @eventResize()

    eventResize: =>
      @canvas.width = Math.floor(document.body.clientWidth / @scale)
      @canvas.height = Math.floor(document.body.clientHeight / @scale)
      @setWidth( @canvas.width )
      @setHeight( @canvas.height )

    setWidth: (@width) ->
      #empty

    setHeight: (@height) ->
      #empty

    addObject: (object) ->
      @objects.push(object)

    draw: (context, interp) ->
      context.save()
      context.fillStyle = @color
      context.fillRect(0, 0, @width, @height)
      context.restore()

      obj.draw(context, interp) for obj in @objects

      if @displayFPS
        @drawFPS()

    update: ->
      @updateObject(obj) for obj in @objects

    updateObject: (object) ->
      object.update()

    drawFPS: ->
      @frametimes.push( (new Date()).getTime() )
      if @frametimes.length > 10
        @frametimes.shift()

      #milleseconds per frame
      mspf = (@frametimes[@frametimes.length - 1] - @frametimes[0]) /
        @frametimes.length

      fps = parseInt(1 / mspf * 1000)

      @context.fillStyle = "rgb(255,255,255)"
      @context.strokeStyle = "rgb(0,0,0)"
      @context.textBaseline = "bottom"
      @context.font = (2 / @scale).toString() + "em Arial"
      @context.fillText('FPS: ' + fps, 5, this.height)
      @context.strokeText('FPS: ' + fps, 5, this.height)

    run: =>
      loops = 0
      while (new Date).getTime() > @next_tick && loops < @max_frameskip:
        @update()
        @next_tick += @tick_time
        loops += 1

      interp = ((new Date).getTime() + @tick_time - @next_tick) / @tick_time
      @draw(@context, interp)

      @requestAnimFrame(@run)

    requestAnimFrame:  ->
      return  window.requestAnimationFrame       ||
              window.webkitRequestAnimationFrame ||
              window.mozRequestAnimationFrame    ||
              window.oRequestAnimationFrame      ||
              window.msRequestAnimationFrame     ||
              (callback, element) ->
                window.setTimeout(callback, 1000 / 60)

  module =
    World: World
    BaseEntity: BaseEntity

  return module
