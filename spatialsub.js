define(function(object) {

function SpatialSub(object) {

  //replace constructor to set subdivision percentage
  object.prototype._spatialsub_constructor = object.prototype.constructor;
  object.prototype.constructor = function(canvas) {
    this._spatialsub_constructor(canvas);
    this.spatialsubs = new Array;
    this.subPercentage = 0.05;
    this.createSpatialSub();
  }

  //replace addObject to put the objects in a spatially subdivided world
  object.prototype._spatialsub_addObject = object.prototype.addObject;
  object.prototype.addObject = function(object) {
    this.addObjectToSpatialSub(object);
    this._spatialsub_addObject(object);
  }

  //replace updateObject function to track objects spatial sub position
  object.prototype._spatialsub_updateObject = object.prototype.updateObject;
  object.prototype.updateObject = function(object) {
    //get current SS position
    var oldquadx = parseInt(object.x / this.subSize);
    var oldquady = parseInt(object.y / this.subSize);

    this._spatialsub_updateObject(object);

    //get new SS position
    var newquadx = parseInt(object.x / this.subSize);
    var newquady = parseInt(object.y / this.subSize);

    //update SS info
    ocean.updateObjectSpatialSub(object, oldquadx, oldquady, newquadx, newquady);
  }

  object.prototype.calculateSpatialSubs = function() {
    this.subSize = this.width * this.subPercentage;
  }

  object.prototype.createSpatialSub = function() {
    this.calculateSpatialSubs();
    var numx = parseInt(this.width / this.subSize) + 1
    var numy = parseInt(this.height / this.subSize) + 1
    var ss = new Array(numx);
    for (var x = 0; x < numx; x++) {
      ss[x] = new Array(numy);
      for (var y = 0; y < numy; y++) {
        ss[x][y] = new Array();
      }
    }
    this.spatialsubs = ss;

  }

  object.prototype.addObjectToSpatialSub = function(object) {
    var subx = parseInt(object.x / this.subSize);
    var suby = parseInt(object.y / this.subSize);
    this.spatialsubs[subx][suby].push(object);
  }

  object.prototype.updateObjectSpatialSub = function(obj, oldx, oldy, newx, newy) {
    if (oldx == newx && oldy == newy) { return }
    var q = this.spatialsubs[oldx][oldy]
    var index = q.indexOf(obj);
    q.splice(index,1);
    this.spatialsubs[newx][newy].push(obj);
  }

  object.prototype.getNeighbors = function(object) {
    var subx = parseInt(object.x / this.subSize);
    var suby = parseInt(object.y / this.subSize);
    var neighbors = new Array();

    for(var x = -1; x <= 1; x++) {
      for (var y = -1; y <=1; y++) {
        var tmpx = subx + x;
        var tmpy = suby + y;
        var maxx = this.spatialsubs.length - 1;
        var maxy = this.spatialsubs[0].length - 1;

        //wrap around compensation
        if (tmpx < 0) { tmpx = maxx + tmpx; }
        if (tmpy < 0) { tmpy = maxy + tmpy; }
        if (tmpx > maxx) { tmpx = tmpx - maxx; }
        if (tmpy > maxy) { tmpy = tmpy - maxy; }
        neighbors = neighbors.concat(this.spatialsubs[tmpx][tmpy].slice(0));
        var index = neighbors.indexOf(object)
        if (index >=0) { neighbors.splice(index,1); }
      }
    }

    return neighbors;
  }

  //TODO: lots of object.x, object.y / this.subSize.  Could be abstracted

  //replace eventResize to update subdivisions
  //object.prototype._sptialsub_eventResize

  return object;
}
return SpatialSub;

});
