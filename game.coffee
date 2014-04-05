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

  change_x: (dx) -> new Point(@x + dx, @y     )
  change_y: (dy) -> new Point(@x     , @y + dy)

  compare_x: (p) ->
    if @x < p.x      then -1
    else if @x > p.x then 1
    else                  0

  compare_y: (p) ->
    if @y < p.y      then -1
    else if @y > p.y then 1
    else                  0

class Rect
  constructor: (@top_left, @width, @height) ->

  top_y:    () -> @top_left.y
  bottom_y: () -> @top_y() + @height
  left_x:   () -> @top_left.x
  right_x:  () -> @left_x() + @width

  includes_point: (p) ->
    (@left_x() <= p.x <= @right_x()) and (@top_y() <= p.y <= @bottom_y())

  center: () ->
    new Point(@left_x() + 0.5 * @width, @top_y() + 0.5 * @height)

  bottom_left: () -> new Point(@left_x(), @bottom_y())
  top_right: () -> new Point(@right_x(), @top_y())
  bottom_right: () -> new Point(@right_x(), @bottom_y())

  change_x: (dx) -> new Rect(@top_left.change_x(dx), @width, @height)
  change_y: (dy) -> new Rect(@top_left.change_y(dy), @width, @height)

class Circle
  constructor: (@center, @radius) ->

  includes_point: (p) ->
    @center.distance_to(p) <= @radius

  change_x: (dx) -> new Circle(@center.change_x(dx), @radius)
  change_y: (dy) -> new Circle(@center.change_y(dy), @radius)

collides = (x, y) ->
  if x instanceof Rect and y instanceof Rect
    for corner in [y.top_left, y.bottom_left(), y.top_right(), y.bottom_right()]
      return true if x.includes_point(corner)
    for corner in [x.top_left, x.bottom_left(), x.top_right(), x.bottom_right()]
      return true if y.includes_point(corner)
    false

class Wall
  constructor: (@rect) ->

  push: (shape, move_x, move_y) ->
    rect = () ->
      if shape instanceof Rect
        shape
      else if shape instanceof Circle
        r = shape.radius
        new Rect(new Point(shape.center.x - r, shape.center.y - r), 2 * r, 2 * r)

    this_center = @rect.center()
    that_center = rect().center()
    dx = that_center.compare_x(this_center)
    dy = that_center.compare_y(this_center)

    while collides(@rect, rect())
      if move_x
        shape = shape.change_x(dx)
      if move_y
        shape = shape.change_y(dy)

    shape

  draw: () ->
    ctx.fillStyle = 'black'
    ctx.fillRect(@rect.left_x(), @rect.top_y(), @rect.width, @rect.height)

class Player
  constructor: (@circle) ->
    @angle = 1.5 * Math.PI # down
    @speed = 3 # pixels per frame

  draw: () ->
    ctx.beginPath()
    ctx.arc(@circle.center.x, @circle.center.y, @circle.radius, 0, 2 * Math.PI, false)
    ctx.fillStyle = 'red'
    ctx.fill()

  update: () ->
    move_down  = key_down
    move_up    = key_up
    move_left  = key_left
    move_right = key_right

    moving = true
    if move_down and move_up
      move_down = move_up = false
    if move_left and move_right
      move_left = move_right = false
    @angle = Math.PI *
      if move_down
        if move_left then 0.75
        else if move_right then 0.25
        else 0.5
      else if move_up
        if move_left then 1.25
        else if move_right then 1.75
        else 1.5
      else
        if move_left then 1
        else if move_right then 0
        else moving = false; @angle

    if moving
      dx = @speed * Math.cos(@angle)
      dy = @speed * Math.sin(@angle)
      @circle = new Circle(new Point(@circle.center.x + dx, @circle.center.y + dy), @circle.radius)
      for wall in walls
        @circle = wall.push(@circle, move_left or move_right, move_up or move_down)

$(document).ready () ->

  canvas = $('#canvas')[0]
  ctx = canvas.getContext '2d'

  $(document).keydown (evt) ->
    switch evt.which
      when 37 then key_left  = true
      when 38 then key_up    = true
      when 39 then key_right = true
      when 40 then key_down  = true

  $(document).keyup (evt) ->
    switch evt.which
      when 37 then key_left  = false
      when 38 then key_up    = false
      when 39 then key_right = false
      when 40 then key_down  = false

  window.requestAnimFrame = (->
    window.requestAnimationFrame or
    window.webkitRequestAnimationFrame or
    window.mozRequestAnimationFrame or
    window.oRequestAnimationFrame or
    window.msRequestAnimationFrame or
    (callback) ->
      window.setTimeout callback, 1000 / 60
  )()

  walls.push new Wall(new Rect(new Point(300, 100), 30, 100))
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
