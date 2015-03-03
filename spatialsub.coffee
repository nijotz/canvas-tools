define [], () ->

    class SpatialSub
        constructor: (@canvas) ->
            @spatialsubs = new Array
            @subPercentage = 0.05
            @createSpatialSub()

        addObject: (object) ->
          subx = parseInt(object.x / @subSize)
          suby = parseInt(object.y / @subSize)
          @spatialsubs[subx][suby].push(object)

        getQuad: (x, y) ->
          quadx = parseInt(x / @subSize)
          quady = parseInt(y / @subSize)
          return [quadx, quady]

        updateObject: (object, oldx, oldy, newx, newy) ->
          #get current SS position
          oldquadx = parseInt(oldx / @subSize)
          oldquady = parseInt(oldy / @subSize)

          #get new SS position
          newquadx = parseInt(newx / @subSize)
          newquady = parseInt(newy / @subSize)

          #update SS info
          return @updateObjectSpatialSub(object, oldquadx, oldquady, newquadx, newquady)

        updateObjectSpatialSub: (obj, oldx, oldy, newx, newy) ->
            if oldx == newx and oldy == newy
                return [newx, newy]
            quad = @spatialsubs[oldx][oldy]
            index = quad.indexOf(obj)
            quad.splice(index,1)
            @spatialsubs[newx][newy].push(obj)
            return [newx, newy]

        calculateSpatialSubs: ->
          @subSize = @canvas.width * @subPercentage

        createSpatialSub: ->
          @calculateSpatialSubs()
          @numx = parseInt(@canvas.width / @subSize) + 1
          @numy = parseInt(@canvas.height / @subSize) + 1
          ss = new Array(@numx)
          for x in [0...@numx]
              ss[x] = new Array(@numy)
              for y in [0...@numy]
                  ss[x][y] = new Array()
          @spatialsubs = ss

        getNeighbors: (object) ->
            subx = parseInt(object.x / @subSize)
            suby = parseInt(object.y / @subSize)
            neighbors = new Array()

            for x in [-1..1]
                for y in [-1..1]
                    tmpx = subx + x
                    tmpy = suby + y
                    maxx = @spatialsubs.length - 1
                    maxy = @spatialsubs[0].length - 1

                    #wrap around compensation
                    tmpx = maxx + tmpx if tmpx < 0
                    tmpy = maxy + tmpy if tmpy < 0
                    tmpx = tmpx - maxx if tmpx > maxx
                    tmpy = tmpy - maxy if tmpy > maxy
                    neighbors = neighbors.concat(@spatialsubs[tmpx][tmpy].slice(0))
                    index = neighbors.indexOf(object)
                    neighbors.splice(index,1) if index >=0

            return neighbors

    return SpatialSub
