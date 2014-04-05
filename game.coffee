canvas = null
ctx = null

walls  = []
floors = []
bodies = []

key_down = false
key_up = false
key_left = false
key_right = false

shot = false
won = false

class Point
  constructor: (@x, @y) ->

  distance_to: (p) ->
    Math.pow(Math.pow(@x - p.x, 2) + Math.pow(@y - p.y, 2), 0.5)

  change_x: (dx) -> new Point(@x + dx, @y     )
  change_y: (dy) -> new Point(@x     , @y + dy)

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

  draw: (fill, stroke = null, stroke_width = 3) ->
    ctx.fillStyle = fill
    ctx.fillRect(@left_x(), @top_y(), @width, @height)
    if stroke
      ctx.lineWidth = stroke_width
      ctx.strokeStyle = stroke
      ctx.strokeRect(@left_x(), @top_y(), @width, @height)

class Circle
  constructor: (@center, @radius) ->

  includes_point: (p) ->
    @center.distance_to(p) <= @radius

  change_x: (dx) -> new Circle(@center.change_x(dx), @radius)
  change_y: (dy) -> new Circle(@center.change_y(dy), @radius)

  draw: (fill, stroke = null, stroke_width = 3) ->
    ctx.beginPath()
    ctx.arc(@center.x, @center.y, @radius, 0, 2 * Math.PI, false)
    ctx.fillStyle = fill
    ctx.fill()
    if stroke
      ctx.lineWidth = stroke_width
      ctx.strokeStyle = stroke
      ctx.stroke()
    ctx.closePath()

collides = (x, y) ->
  if x instanceof Rect
    if y instanceof Rect
      for corner in [y.top_left, y.bottom_left(), y.top_right(), y.bottom_right()]
        return true if x.includes_point(corner)
      for corner in [x.top_left, x.bottom_left(), x.top_right(), x.bottom_right()]
        return true if y.includes_point(corner)
      false
    else if y instanceof Circle
      x.includes_point(y.center) or
        x.includes_point(y.center.change_x(y.radius)) or
        x.includes_point(y.center.change_x(-(y.radius))) or
        x.includes_point(y.center.change_y(y.radius)) or
        x.includes_point(y.center.change_y(-(y.radius))) or
        y.includes_point(x.top_left) or
        y.includes_point(x.bottom_left()) or
        y.includes_point(x.top_right()) or
        y.includes_point(x.bottom_right())
  else if x instanceof Circle
    if y instanceof Rect
      collides(y, x)
    else if y instanceof Circle
      x.center.distance_to(y.center) <= x.radius + y.radius

class Wall
  constructor: (@shape) ->

  push: (shape, push_x, push_y) ->
    while collides(@shape, shape)
      shape = shape.change_x(push_x).change_y(push_y)
    shape

  draw: () ->
    @shape.draw('black')

class SwitchWall extends Wall
  constructor: (@shape, @color) ->

  open: () ->
    for floor in floors
      if floor instanceof Switch
        return true if floor.color is @color and floor.pressed
    false

  push: (shape, push_x, push_y) ->
    if @open() then shape else super

  draw: () ->
    return if @open()
    @shape.draw(@color)

class Player
  constructor: (@circle) ->
    @angle = 1.5 * Math.PI # down
    @speed = 6 # pixels per frame

  draw: () ->
    @circle.draw('gray')

  update: () ->
    return false if shot

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
      @circle = @circle.change_x(dx).change_y(dy)
      push_x = if move_left then 1 else if move_right then -1 else 0
      push_y = if move_up   then 1 else if move_down  then -1 else 0
      for wall in walls
        @circle = wall.push(@circle, push_x, push_y)

    true

class Switch
  constructor: (@circle, @color, @pressed = false) ->

  draw: () ->
    @circle.draw(@color, 'black', 2)
    if @pressed
      ctx.fillStyle = 'white'
      ctx.fillRect(@circle.center.x - 2, @circle.center.y - 2, 4, 4)

  update: () ->
    for body in bodies
      if body instanceof Player
        @pressed = true if collides(@circle, body.circle)
    true

class Turret
  constructor: (@circle) ->
    @timer = 0
    @goal = 30

  draw: () ->
    @circle.draw('gray', 'black', @timer / 3)

  update: () ->
    if @timer >= @goal
      @timer = 0
    else
      @timer += 1
    true

  spawn: () ->
    if @timer >= @goal
      player = null
      for body in bodies
        if body instanceof Player
          player = body
          break
      if player
        target = player.circle.center
        dx = target.x - @circle.center.x
        dy = target.y - @circle.center.y
        angle = Math.atan2(dy, dx)
        return [new Bullet(new Circle(@circle.center, 5), angle)]
    []

class Bullet
  constructor: (@shape, @angle) ->
    @speed = 8

  draw: () ->
    @shape.draw('magenta')

  update: () ->
    dx = @speed * Math.cos(@angle)
    dy = @speed * Math.sin(@angle)
    @shape = @shape.change_x(dx).change_y(dy)
    for wall in walls
      return false if collides(@shape, wall.shape)
    for body in bodies
      if body instanceof Player
        if collides(body.circle, @shape)
          shot = true
          return false
    true

class Goal
  constructor: (@circle) ->

  draw: () ->
    @circle.draw('orange')

  update: () ->
    for body in bodies
      if body instanceof Player
        if collides(body.circle, @circle)
          won = true
    true

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

  canvas.width = 820
  canvas.height = 520

  walls.push new Wall(new Rect(new Point(0, 0), 20, canvas.height))
  walls.push new Wall(new Rect(new Point(0, 0), canvas.width, 20))
  walls.push new Wall(new Rect(new Point(canvas.width - 20, 0), 20, canvas.height))
  walls.push new Wall(new Rect(new Point(0, canvas.height - 20), canvas.width, 20))

  walls.push new Wall(new Rect(new Point(100, 0), 20, 200))
  walls.push new Wall(new Rect(new Point(100, 320), 20, 200))
  bodies.push new Player(new Circle(new Point(60, 60), 15))
  floors.push new Switch(new Circle(new Point(60, canvas.height - 60), 10), 'blue')

  walls.push new SwitchWall(new Rect(new Point(200, 20), 20, 80), 'lime')
  walls.push new Wall(new Rect(new Point(200, 100), 20, 100))

  walls.push new Wall(new Rect(new Point(200, 320), 20, 100))
  walls.push new SwitchWall(new Rect(new Point(200, 420), 20, 80), 'red')

  walls.push new Wall(new Rect(new Point(200, 100), 400, 20))
  walls.push new Wall(new Rect(new Point(200, 400), 400, 20))

  walls.push new Wall(new Rect(new Point(580, 100), 20, 320))


  walls.push new SwitchWall(new Rect(new Point(200, 200), 100, 20), 'blue')
  walls.push new SwitchWall(new Rect(new Point(200, 300), 100, 20), 'yellow')

  walls.push new Wall(new Rect(new Point(300, 200), 300, 20))
  walls.push new Wall(new Rect(new Point(300, 300), 400, 20))


  walls.push new Wall(new Rect(new Point(680, 420), 20, 80))

  bodies.push new Turret(new Circle(new Point(400, 260), 7))
  floors.push new Switch(new Circle(new Point(530, 160), 10), 'lime')
  floors.push new Switch(new Circle(new Point(530, 360), 10), 'red')
  floors.push new Goal(new Circle(new Point(640, 460), 15))
  floors.push new Switch(new Circle(new Point(760, 60), 10), 'yellow')
  bodies.push new Turret(new Circle(new Point(760, 310), 7))

  #floors.push new Goal(new Circle(new Point(400, 60), 15))

  (animloop = ->
    requestAnimFrame animloop

    new_bodies = []
    for body in bodies
      new_bodies.push(body) if body.update()
      new_bodies = new_bodies.concat(body.spawn()) if body.spawn
    bodies = new_bodies
    new_floors = []
    for floor in floors
      new_floors.push(floor) if floor.update()
    floors = new_floors

    ctx.fillStyle = if shot then 'maroon' else if won then 'green' else 'white'
    ctx.fillRect(0, 0, canvas.width, canvas.height)

    for floor in floors
      floor.draw()
    for body in bodies
      body.draw()
    for wall in walls
      wall.draw()
  )()
