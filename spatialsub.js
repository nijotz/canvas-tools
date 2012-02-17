define(function(object) {

function SpatialSub(object) {

  //replace constructor to set subdivision percentage
  object.prototype._spatialsub_constructor = object.prototype.constructor;
  object.prototype.constructor = function(canvas) {
    this._spatialsub_constructor(canvas);
    this.spatialsubs = new Array;
    this.subPercentage = 0.05;
    this.calculateSpatialSubs();
  }

  //replace addObject to put the objects in a spatially subdivided world
  object.prototype._spatialsub_addObject = object.prototype.addObject;
  object.prototype.addObject = function(object) {
    this.addObjectToSpatialSubs(object);
    this._spatialsub_addObject(object);
  }

  object.prototype.calculateSpatialSubs = function() {
    this.subSize = this.width * this.subPercentage;
  }

  object.prototype.createSpatialSub = function(collidable) {
    var numx = parseInt(this.width / this.subSize) + 1
    var numy = parseInt(this.height / this.subSize) + 1
    var ss = new Array(numx);
    for (var x = 0; x < numx; x++) {
      ss[x] = new Array(numy);
      for (var y = 0; y < numy; y++) {
        ss[x][y] = new Array();
      }
    }
    this.spatialsubs[collidable] = ss;

  }

  object.prototype.addObjectToSpatialSub = function(object, collidable) {
    var subx = parseInt(object.x / this.subSize);
    var suby = parseInt(object.y / this.subSize);
    this.spatialsubs[collidable][subx][suby].push(object);
  }

  object.prototype.addObjectToSpatialSubs = function(object) {
    var objs = object.collidableObjects;
    if (objs) {
      for (var i = 0; i < objs.length; i++) {
        var collidable = objs[i];
        if (!this.spatialsubs[collidable]) {
          this.createSpatialSub(collidable);
        }
        this.addObjectToSpatialSub(object, collidable);
      }
    }
  }

  //replace eventResize to update subdivisions
  //object.prototype._sptialsub_eventResize

  return object;
}
return SpatialSub;

});
