define(function() {


World.prototype = new Object;
World.prototype.constructor = World;
function World(canvas) {
  this.objects = new Array();
  this.width = 320;
  this.height = 240;
  this.frametimes = new Array();
  this.ticks = 30;
  this.objects = new Array();

  this.setCanvas(canvas);
  
  window.addEventListener('resize', this.properlyScopedEventHandler(this.eventResize), false);
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
  this.eventResize();
  //this.setWidth(parseInt(canvas.getAttribute('width')));
  //this.setHeight(parseInt(canvas.getAttribute('height')));
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
  c.fillStyle = "rgb(10,50,100)";
  c.fillRect(0, 0, this.width, this.height);

  for (var i in this.objects) {this.objects[i].draw()}
  this.drawFPS();
}

World.prototype.update = function() {
  for (var i in this.objects) {this.objects[i].update()}
}

World.prototype.drawFPS = function() {
  this.frametimes.push((new Date()).getTime());
  if (this.frametimes.length > 10) {this.frametimes.shift()}
  //milleseconds per frame
  var mspf = (this.frametimes[this.frametimes.length - 1] -
              this.frametimes[0]) / this.frametimes.length;
  var fps = parseInt(1 / mspf * 1000);
  this.context.fillStyle = "rgb(0,0,0)";
  this.context.font = "2em Arial";
  this.context.textBaseline = "bottom";
  this.context.fillText('FPS: ' + fps, 5, this.height);
}

window.requestAnimFrame = function(callback) { window.setTimeout(callback, 1000 / 60) };
//window.requestAnimFrame = (function(){
//  return  window.requestAnimationFrame       ||
//          window.webkitRequestAnimationFrame ||
//          window.mozRequestAnimationFrame    ||
//          window.oRequestAnimationFrame      ||
//          window.msRequestAnimationFrame     ||
//          function(callback, element) {
//            window.setTimeout(callback, 1000 / 60);
//          };
//})();

World.prototype.run = function(scope) {
  scope = typeof(scope) != 'undefined' ? scope : this;

  this.draw();
  this.update();

  requestAnimFrame(function() {scope.run.call(scope, scope)});
}

return World;

});
