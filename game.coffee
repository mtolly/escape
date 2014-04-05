canvas = null
ctx = null

walls  = []
floors = []
bodies = []

class Point
  constructor: (@x, @y) ->

  distance_to: (p) ->
    Math.pow(Math.pow(@x - p.x, 2) + Math.pow(@y - p.y, 2), 0.5)

class Rect
  constructor: (@top_left, @width, @height) ->

  includes_point: (p) ->
    (@top_left.x <= p.x <= @top_left.x + @width) and (@top_left.y <= p.y <= @top_left.y + @height)

class Circle
  constructor: (@center, @radius) ->

  includes_point: (p) ->
    @center.distance_to(p) <= @radius

class Player
  constructor: (@circle) ->

  draw: () ->
    ctx.beginPath()
    ctx.arc(@circle.center.x, @circle.center.y, @circle.radius, 0, 2 * Math.PI, false)
    ctx.fillStyle = 'red'
    ctx.fill()

  update: () ->

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

  bodies.push new Player(new Circle(new Point(100, 200), 25))

  (animloop = ->
    requestAnimFrame animloop

    for body in bodies
      body.update()

    ctx.fillStyle = 'white'
    ctx.fillRect(0, 0, canvas.width, canvas.height)

    for floor in floors
      floor.draw()

    for wall in walls
      wall.draw()
    
    for body in bodies
      body.draw()
  )()
