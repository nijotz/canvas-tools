define ['jquery'], ($) ->

  #TODO: how to handle scaling and entities using document.body.clientWidth or event.clientX?
  
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
      @scale = 1 # Ratio of screen pixels to canvas pixels
      @frametimes = []
      @ticks = 30
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
      @context.textBaseline = "bottom"
      @context.fillText('FPS: ' + fps, 5, this.height)
      @context.strokeText('FPS: ' + fps, 5, this.height)

    # TODO: no no no, seperate draw and update loops
    # from flow/world.cpp:
    #
    # void World::run()
    # {
    #   //TODO: assure NDEBUG for release build
    #   assert(initialized);
    # 
    #   int loops = 0;
    #   float interp = 0.0f; // track percentage of the way to next tick
    #   Uint32 next_tick = SDL_GetTicks();
    # 
    #   while (quit == false) {
    # 
    #     //Call think() every tick. If think takes so long that it needs to be called
    #     //again immediately, call it again.  But don't go more than MAX_FRAMESKIP
    #     //ticks without rendering a frame.
    #     loops = 0;
    #     while (SDL_GetTicks() > next_tick && loops < MAX_FRAMESKIP) {
    #       think();
    #       next_tick += SKIP_TICKS;
    #       loops++;
    #     }
    # 
    #     //time_to_next_update = next_tick - SDL_GetTicks();
    #     interp = float(SKIP_TICKS - (next_tick - SDL_GetTicks())) /
    #              float(SKIP_TICKS);
    #     draw(interp);
    #   }
    # 
    #   clean_up();
    # }
      @context.font = (2 / @scale).toString() + "em Arial"
      @context.fillText('FPS: ' + fps, 5, @height)
      @context.strokeText('FPS: ' + fps, 5, @height)

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
