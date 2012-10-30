define ['jquery'], ($) ->
  
  class BaseEntity
    constructor: (@world) ->
      @updaters = []

    addUpdater: (callback, sequence = 0) ->
      callback.sequence = sequence
      @updaters.push(callback)
      @updaters.sort((a,b) -> return a.sequence - b.sequence)

    update: (interp) ->
      for updater in @updaters
        updater.call(this, interp)

  class World
    constructor: (canvas) ->
      @objects = []
      @width = 0
      @height = 0
      @frametimes = []
      @ticks = 30
      @objects = []
      @color = "rgb(0,0,0)"
      @displayFPS = false

      @setCanvas(canvas)
      window.addEventListener('resize', @eventResize, false);

    setCanvas: (@canvas) ->
      @context = @canvas.getContext('2d')
      @eventResize()

    eventResize: =>
      @canvas.width = document.body.clientWidth
      @canvas.height = document.body.clientHeight
      @setWidth( $(@canvas).width() )
      @setHeight( $(@canvas).height() )

    setWidth: (@width) ->
      #empty

    setHeight: (@height) ->
      #empty

    addObject: (object) ->
      @objects.push(object)

    draw: ->
      @context.save()
      @context.fillStyle = @color
      @context.fillRect(0, 0, @width, @height)
      @context.restore()

      obj.draw(@context) for obj in @objects

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
      @context.font = "2em Arial"
      @context.textBaseline = "bottom"
      @context.fillText('FPS: ' + fps, 5, this.height)
      @context.strokeText('FPS: ' + fps, 5, this.height)

    run: =>
      @draw()
      @update()

      #@requestAnimFrame(this)
      window.mozRequestAnimationFrame(@run)

    requestAnimFrame:  ->
      return window.mozRequestAnimationFrame
      #return window.requestAnimationFrame
      #return  window.requestAnimationFrame       ||
      #        window.webkitRequestAnimationFrame ||
      #        window.mozRequestAnimationFrame    ||
      #        window.oRequestAnimationFrame      ||
      #        window.msRequestAnimationFrame     ||
      #        (callback, element) ->
      #          window.setTimeout(callback, 1000 / 60)
      #)


  module =
    World: World
    BaseEntity: BaseEntity

  return module
