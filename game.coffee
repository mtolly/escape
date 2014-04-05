canvas = null
ctx = null

walls  = []
floors = []
bodies = []

key_down = false
key_up = false
key_left = false
key_right = false

class Point
  constructor: (@x, @y) ->

  distance_to: (p) ->
    Math.pow(Math.pow(@x - p.x, 2) + Math.pow(@y - p.y, 2), 0.5)

class Rect
  constructor: (@top_left, @width, @height) ->

  top_y:    () -> @top_left.y
  bottom_y: () -> @top_y() + @height
  left_x:   () -> @top_left.x
  right_x:  () -> @left_x() + @width

  includes_point: (p) ->
    (@left_x() <= p.x <= @right_x()) and (@top_y() <= p.y <= @bottom_y())

class Circle
  constructor: (@center, @radius) ->

  includes_point: (p) ->
    @center.distance_to(p) <= @radius

class Wall
  constructor: (@rect) ->

  push: (shape, dir) ->
    shape # TODO

  draw: () ->
    ctx.fillStyle = 'black'
    ctx.fillRect(@rect.left_x(), @rect.top_y(), @rect.width, @rect.height)

class Player
  constructor: (@circle) ->
    @angle = 1.5 * Math.PI # down
    @speed = 1 # pixels per frame

  draw: () ->
    ctx.beginPath()
    ctx.arc(@circle.center.x, @circle.center.y, @circle.radius, 0, 2 * Math.PI, false)
    ctx.fillStyle = 'red'
    ctx.fill()

  update: () ->
    move_down  = true
    move_up    = false
    move_left  = false
    move_right = false
    # TODO

$(document).ready () ->

  canvas = $('#canvas')[0]
  ctx = canvas.getContext '2d'

  window.requestAnimFrame = (->
    window.requestAnimationFrame or
    window.webkitRequestAnimationFrame or
    window.mozRequestAnimationFrame or
    window.oRequestAnimationFrame or
    window.msRequestAnimationFrame or
    (callback) ->
      window.setTimeout callback, 1000 / 60
  )()

  walls.push new Wall(new Rect(new Point(10, 10), 30, 100))
  bodies.push new Player(new Circle(new Point(100, 200), 25))

  (animloop = ->
    requestAnimFrame animloop

    for body in bodies
      body.update()
    for floor in floors
      floor.update()

    ctx.fillStyle = 'white'
    ctx.fillRect(0, 0, canvas.width, canvas.height)

    for floor in floors
      floor.draw()
    for wall in walls
      wall.draw()
    for body in bodies
      body.draw()
  )()
