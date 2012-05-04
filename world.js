define(function() {

BaseEntity.prototype = new Object;
BaseEntity.prototype.constructor = BaseEntity;
function BaseEntity(world) {
  this.world = world;
  this.updaters = [];
}

BaseEntity.prototype.addUpdater = function(callback, sequence) {
  sequence = (typeof sequence == 'undefined') ? 0 : sequence;
  callback.sequence = sequence;
  this.updaters.push(callback);
  this.updaters.sort(function(a,b) {
    return a.sequence - b.sequence
  });
}

BaseEntity.prototype.update = function(interp) {
  for (var i = 0; i < this.updaters.length; i++) {
    this.updaters[i].call(this, interp);
  }
}

World.prototype = new Object;
World.prototype.constructor = World;
function World(canvas) {
  this.objects = new Array();
  this.width = 320;
  this.height = 240;
  this.frametimes = new Array();
  this.ticks = 30;
  this.objects = new Array();
  this.color = "rgb(0,0,0)";
  this.displayFPS = false;

  this.setCanvas(canvas);
  //window.addEventListener('resize', this.properlyScopedEventHandler(this.eventResize), false);
}

World.prototype.properlyScopedEventHandler = function(f) {
  var scope = this;
  return function(evt) { f.call(scope, evt) }
}

World.prototype.setWidth = function(w) { this.width = w; }
World.prototype.setHeight = function(h) { this.height = h; }

World.prototype.setCanvas = function(canvas) {
  this.canvas = canvas;
  this.context = canvas.getContext('2d');
  //this.eventResize();
  this.setWidth(parseInt(canvas.getAttribute('width')));
  this.setHeight(parseInt(canvas.getAttribute('height')));
}

World.prototype.eventResize = function() {
  this.canvas.width = document.body.clientWidth;
  this.canvas.height = document.body.clientHeight;
  this.setWidth(document.body.clientWidth);
  this.setHeight(document.body.clientHeight);
}

World.prototype.addObject = function(object) {
  this.objects.push(object);
}

World.prototype.draw = function() {
  var c = this.context;

  c.save();
  c.fillStyle = this.color;
  c.fillRect(0, 0, this.width, this.height);
  c.restore();

  for (var i in this.objects) {this.objects[i].draw(c)}

  if (this.displayFPS) { this.drawFPS(); }
}

World.prototype.update = function() {
  for (var i in this.objects) {this.updateObject(this.objects[i])}
}

World.prototype.updateObject = function(object) {
  object.update()
}

World.prototype.drawFPS = function() {
  this.frametimes.push((new Date()).getTime());
  if (this.frametimes.length > 10) {this.frametimes.shift()}
  //milleseconds per frame
  var mspf = (this.frametimes[this.frametimes.length - 1] -
              this.frametimes[0]) / this.frametimes.length;
  var fps = parseInt(1 / mspf * 1000);
  this.context.fillStyle = "rgb(255,255,255)";
  this.context.strokeStyle = "rgb(0,0,0)";
  this.context.font = "2em Arial";
  this.context.textBaseline = "bottom";
  this.context.fillText('FPS: ' + fps, 75, this.height);
  this.context.strokeText('FPS: ' + fps, 75, this.height);
}

//window.requestAnimFrame = function(callback) { window.setTimeout(callback, 1000 / 60) };
window.requestAnimFrame = (function(){
  return  window.requestAnimationFrame       ||
          window.webkitRequestAnimationFrame ||
          window.mozRequestAnimationFrame    ||
          window.oRequestAnimationFrame      ||
          window.msRequestAnimationFrame     ||
          function(callback, element) {
            window.setTimeout(callback, 1000 / 60);
          };
})();

World.prototype.run = function(scope) {
  scope = typeof(scope) != 'undefined' ? scope : this;

  this.draw();
  this.update();

  requestAnimFrame(function() {scope.run.call(scope, scope)});
}

return {
  'World': World,
  'BaseEntity' :BaseEntity
}

});
