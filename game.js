// Generated by CoffeeScript 1.4.0
(function() {
  var Bullet, Circle, Goal, Player, Point, Rect, Switch, SwitchWall, Turret, Wall, bodies, canvas, collides, ctx, floors, key_down, key_left, key_right, key_up, shot, walls, won,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  canvas = null;

  ctx = null;

  walls = [];

  floors = [];

  bodies = [];

  key_down = false;

  key_up = false;

  key_left = false;

  key_right = false;

  shot = false;

  won = false;

  Point = (function() {

    function Point(x, y) {
      this.x = x;
      this.y = y;
    }

    Point.prototype.distance_to = function(p) {
      return Math.pow(Math.pow(this.x - p.x, 2) + Math.pow(this.y - p.y, 2), 0.5);
    };

    Point.prototype.change_x = function(dx) {
      return new Point(this.x + dx, this.y);
    };

    Point.prototype.change_y = function(dy) {
      return new Point(this.x, this.y + dy);
    };

    return Point;

  })();

  Rect = (function() {

    function Rect(top_left, width, height) {
      this.top_left = top_left;
      this.width = width;
      this.height = height;
    }

    Rect.prototype.top_y = function() {
      return this.top_left.y;
    };

    Rect.prototype.bottom_y = function() {
      return this.top_y() + this.height;
    };

    Rect.prototype.left_x = function() {
      return this.top_left.x;
    };

    Rect.prototype.right_x = function() {
      return this.left_x() + this.width;
    };

    Rect.prototype.includes_point = function(p) {
      var _ref, _ref1;
      return ((this.left_x() <= (_ref = p.x) && _ref <= this.right_x())) && ((this.top_y() <= (_ref1 = p.y) && _ref1 <= this.bottom_y()));
    };

    Rect.prototype.center = function() {
      return new Point(this.left_x() + 0.5 * this.width, this.top_y() + 0.5 * this.height);
    };

    Rect.prototype.bottom_left = function() {
      return new Point(this.left_x(), this.bottom_y());
    };

    Rect.prototype.top_right = function() {
      return new Point(this.right_x(), this.top_y());
    };

    Rect.prototype.bottom_right = function() {
      return new Point(this.right_x(), this.bottom_y());
    };

    Rect.prototype.change_x = function(dx) {
      return new Rect(this.top_left.change_x(dx), this.width, this.height);
    };

    Rect.prototype.change_y = function(dy) {
      return new Rect(this.top_left.change_y(dy), this.width, this.height);
    };

    Rect.prototype.draw = function(fill, stroke, stroke_width) {
      if (stroke == null) {
        stroke = null;
      }
      if (stroke_width == null) {
        stroke_width = 3;
      }
      ctx.fillStyle = fill;
      ctx.fillRect(this.left_x(), this.top_y(), this.width, this.height);
      if (stroke) {
        ctx.lineWidth = stroke_width;
        ctx.strokeStyle = stroke;
        return ctx.strokeRect(this.left_x(), this.top_y(), this.width, this.height);
      }
    };

    return Rect;

  })();

  Circle = (function() {

    function Circle(center, radius) {
      this.center = center;
      this.radius = radius;
    }

    Circle.prototype.includes_point = function(p) {
      return this.center.distance_to(p) <= this.radius;
    };

    Circle.prototype.change_x = function(dx) {
      return new Circle(this.center.change_x(dx), this.radius);
    };

    Circle.prototype.change_y = function(dy) {
      return new Circle(this.center.change_y(dy), this.radius);
    };

    Circle.prototype.draw = function(fill, stroke, stroke_width) {
      if (stroke == null) {
        stroke = null;
      }
      if (stroke_width == null) {
        stroke_width = 3;
      }
      ctx.beginPath();
      ctx.arc(this.center.x, this.center.y, this.radius, 0, 2 * Math.PI, false);
      ctx.fillStyle = fill;
      ctx.fill();
      if (stroke) {
        ctx.lineWidth = stroke_width;
        ctx.strokeStyle = stroke;
        ctx.stroke();
      }
      return ctx.closePath();
    };

    return Circle;

  })();

  collides = function(x, y) {
    var corner, _i, _j, _len, _len1, _ref, _ref1;
    if (x instanceof Rect) {
      if (y instanceof Rect) {
        _ref = [y.top_left, y.bottom_left(), y.top_right(), y.bottom_right()];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          corner = _ref[_i];
          if (x.includes_point(corner)) {
            return true;
          }
        }
        _ref1 = [x.top_left, x.bottom_left(), x.top_right(), x.bottom_right()];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          corner = _ref1[_j];
          if (y.includes_point(corner)) {
            return true;
          }
        }
        return false;
      } else if (y instanceof Circle) {
        return x.includes_point(y.center) || x.includes_point(y.center.change_x(y.radius)) || x.includes_point(y.center.change_x(-y.radius)) || x.includes_point(y.center.change_y(y.radius)) || x.includes_point(y.center.change_y(-y.radius)) || y.includes_point(x.top_left) || y.includes_point(x.bottom_left()) || y.includes_point(x.top_right()) || y.includes_point(x.bottom_right());
      }
    } else if (x instanceof Circle) {
      if (y instanceof Rect) {
        return collides(y, x);
      } else if (y instanceof Circle) {
        return x.center.distance_to(y.center) <= x.radius + y.radius;
      }
    }
  };

  Wall = (function() {

    function Wall(rect) {
      this.rect = rect;
    }

    Wall.prototype.push = function(shape, push_x, push_y) {
      while (collides(this.rect, shape)) {
        shape = shape.change_x(push_x).change_y(push_y);
      }
      return shape;
    };

    Wall.prototype.draw = function() {
      return this.rect.draw('black');
    };

    return Wall;

  })();

  SwitchWall = (function(_super) {

    __extends(SwitchWall, _super);

    function SwitchWall(rect, color) {
      this.rect = rect;
      this.color = color;
    }

    SwitchWall.prototype.open = function() {
      var floor, _i, _len;
      for (_i = 0, _len = floors.length; _i < _len; _i++) {
        floor = floors[_i];
        if (floor instanceof Switch) {
          if (floor.color === this.color && floor.pressed) {
            return true;
          }
        }
      }
      return false;
    };

    SwitchWall.prototype.push = function(shape, push_x, push_y) {
      if (this.open()) {
        return shape;
      } else {
        return SwitchWall.__super__.push.apply(this, arguments);
      }
    };

    SwitchWall.prototype.draw = function() {
      if (this.open()) {
        return;
      }
      return this.rect.draw(this.color);
    };

    return SwitchWall;

  })(Wall);

  Player = (function() {

    function Player(circle) {
      this.circle = circle;
      this.angle = 1.5 * Math.PI;
      this.speed = 6;
    }

    Player.prototype.draw = function() {
      return this.circle.draw('red');
    };

    Player.prototype.update = function() {
      var dx, dy, move_down, move_left, move_right, move_up, moving, push_x, push_y, wall, _i, _len;
      if (shot) {
        return false;
      }
      move_down = key_down;
      move_up = key_up;
      move_left = key_left;
      move_right = key_right;
      moving = true;
      if (move_down && move_up) {
        move_down = move_up = false;
      }
      if (move_left && move_right) {
        move_left = move_right = false;
      }
      this.angle = Math.PI * (move_down ? move_left ? 0.75 : move_right ? 0.25 : 0.5 : move_up ? move_left ? 1.25 : move_right ? 1.75 : 1.5 : move_left ? 1 : move_right ? 0 : (moving = false, this.angle));
      if (moving) {
        dx = this.speed * Math.cos(this.angle);
        dy = this.speed * Math.sin(this.angle);
        this.circle = new Circle(new Point(this.circle.center.x + dx, this.circle.center.y + dy), this.circle.radius);
        push_x = move_left ? 1 : move_right ? -1 : 0;
        push_y = move_up ? 1 : move_down ? -1 : 0;
        for (_i = 0, _len = walls.length; _i < _len; _i++) {
          wall = walls[_i];
          this.circle = wall.push(this.circle, push_x, push_y);
        }
      }
      return true;
    };

    return Player;

  })();

  Switch = (function() {

    function Switch(circle, color, pressed) {
      this.circle = circle;
      this.color = color;
      this.pressed = pressed != null ? pressed : false;
    }

    Switch.prototype.draw = function() {
      this.circle.draw(this.color, 'black', 2);
      if (this.pressed) {
        ctx.fillStyle = 'white';
        return ctx.fillRect(this.circle.center.x - 2, this.circle.center.y - 2, 4, 4);
      }
    };

    Switch.prototype.update = function() {
      var body, _i, _len;
      for (_i = 0, _len = bodies.length; _i < _len; _i++) {
        body = bodies[_i];
        if (body instanceof Player) {
          if (collides(this.circle, body.circle)) {
            this.pressed = true;
          }
        }
      }
      return true;
    };

    return Switch;

  })();

  Turret = (function() {

    function Turret(circle) {
      this.circle = circle;
      this.timer = 0;
      this.goal = 30;
    }

    Turret.prototype.draw = function() {
      return this.circle.draw('gray', 'black', this.timer / 3);
    };

    Turret.prototype.update = function() {
      if (this.timer >= this.goal) {
        this.timer = 0;
      } else {
        this.timer += 1;
      }
      return true;
    };

    Turret.prototype.spawn = function() {
      var angle, body, dx, dy, player, target, _i, _len;
      if (this.timer >= this.goal) {
        player = null;
        for (_i = 0, _len = bodies.length; _i < _len; _i++) {
          body = bodies[_i];
          if (body instanceof Player) {
            player = body;
            break;
          }
        }
        if (player) {
          target = player.circle.center;
          dx = target.x - this.circle.center.x;
          dy = target.y - this.circle.center.y;
          angle = Math.atan2(dy, dx);
          return [new Bullet(new Circle(this.circle.center, 5), angle)];
        }
      }
      return [];
    };

    return Turret;

  })();

  Bullet = (function() {

    function Bullet(circle, angle) {
      this.circle = circle;
      this.angle = angle;
      this.speed = 8;
    }

    Bullet.prototype.draw = function() {
      return this.circle.draw('magenta');
    };

    Bullet.prototype.update = function() {
      var body, dx, dy, wall, _i, _j, _len, _len1;
      dx = this.speed * Math.cos(this.angle);
      dy = this.speed * Math.sin(this.angle);
      this.circle.center = this.circle.center.change_x(dx).change_y(dy);
      for (_i = 0, _len = walls.length; _i < _len; _i++) {
        wall = walls[_i];
        if (wall.rect.includes_point(this.circle.center)) {
          return false;
        }
      }
      for (_j = 0, _len1 = bodies.length; _j < _len1; _j++) {
        body = bodies[_j];
        if (body instanceof Player) {
          if (collides(body.circle, this.circle)) {
            shot = true;
            return false;
          }
        }
      }
      return true;
    };

    return Bullet;

  })();

  Goal = (function() {

    function Goal(circle) {
      this.circle = circle;
    }

    Goal.prototype.draw = function() {
      return this.circle.draw('orange');
    };

    Goal.prototype.update = function() {
      var body, _i, _len;
      for (_i = 0, _len = bodies.length; _i < _len; _i++) {
        body = bodies[_i];
        if (body instanceof Player) {
          if (collides(body.circle, this.circle)) {
            won = true;
          }
        }
      }
      return true;
    };

    return Goal;

  })();

  $(document).ready(function() {
    var animloop;
    canvas = $('#canvas')[0];
    ctx = canvas.getContext('2d');
    $(document).keydown(function(evt) {
      switch (evt.which) {
        case 37:
          return key_left = true;
        case 38:
          return key_up = true;
        case 39:
          return key_right = true;
        case 40:
          return key_down = true;
      }
    });
    $(document).keyup(function(evt) {
      switch (evt.which) {
        case 37:
          return key_left = false;
        case 38:
          return key_up = false;
        case 39:
          return key_right = false;
        case 40:
          return key_down = false;
      }
    });
    window.requestAnimFrame = (function() {
      return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback) {
        return window.setTimeout(callback, 1000 / 60);
      };
    })();
    walls.push(new Wall(new Rect(new Point(0, 0), 20, canvas.height)));
    walls.push(new Wall(new Rect(new Point(0, 0), canvas.width, 20)));
    walls.push(new Wall(new Rect(new Point(canvas.width - 20, 0), 20, canvas.height)));
    walls.push(new Wall(new Rect(new Point(0, canvas.height - 20), canvas.width, 20)));
    walls.push(new Wall(new Rect(new Point(100, 100), canvas.width - 100, 20)));
    bodies.push(new Player(new Circle(new Point(100, 200), 15)));
    floors.push(new Switch(new Circle(new Point(300, 300), 10), 'blue'));
    walls.push(new SwitchWall(new Rect(new Point(200, 20), 20, 80), 'blue'));
    bodies.push(new Turret(new Circle(new Point(400, 400), 7)));
    floors.push(new Goal(new Circle(new Point(400, 60), 15)));
    return (animloop = function() {
      var body, floor, new_bodies, new_floors, wall, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _results;
      requestAnimFrame(animloop);
      new_bodies = [];
      for (_i = 0, _len = bodies.length; _i < _len; _i++) {
        body = bodies[_i];
        if (body.update()) {
          new_bodies.push(body);
        }
        if (body.spawn) {
          new_bodies = new_bodies.concat(body.spawn());
        }
      }
      bodies = new_bodies;
      new_floors = [];
      for (_j = 0, _len1 = floors.length; _j < _len1; _j++) {
        floor = floors[_j];
        if (floor.update()) {
          new_floors.push(floor);
        }
      }
      floors = new_floors;
      ctx.fillStyle = shot ? 'maroon' : won ? 'green' : 'white';
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      for (_k = 0, _len2 = floors.length; _k < _len2; _k++) {
        floor = floors[_k];
        floor.draw();
      }
      for (_l = 0, _len3 = bodies.length; _l < _len3; _l++) {
        body = bodies[_l];
        body.draw();
      }
      _results = [];
      for (_m = 0, _len4 = walls.length; _m < _len4; _m++) {
        wall = walls[_m];
        _results.push(wall.draw());
      }
      return _results;
    })();
  });

}).call(this);
