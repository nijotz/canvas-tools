define ['canvas-tools/world', 'lib/oliver-fluid/pressure.js'], (World, Pressure) ->

  class FlowWorld extends World.World
    constructor: (canvas) ->
      @source_canvas = document.createElement('canvas')
      super
      @setCanvas(canvas)

    setCanvas: (@canvas) ->
      super
      @source_canvas.width = @canvas.width
      @source_canvas.height = @canvas.height
      @context = @source_canvas.getContext('2d')

    draw: ->
      super
      real_context = @canvas.getContext('2d')
      real_context.drawImage(@source_canvas, 0, 0)

  return FlowWorld
