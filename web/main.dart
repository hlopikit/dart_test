import 'dart:html' as html;
import 'dart:async' as async;
import 'dart:math' as math;
import 'package:stagexl/stagexl.dart' as sxl;


String capFirst(String s) {
  if (s.length == 0) {return s;}
  if (s.length == 1) {return s.toUpperCase();}
  return s[0].toUpperCase() + s.substring(1);
}


class PhotoCut {
  int x, y, width, height;
  sxl.Shape shape;
  sxl.Sprite sprite;
  sxl.Stage stage;
  Map<String, Map<String, sxl.EventStreamSubscription>> _subscriptions;  // Здесь хранятся все event-listener 'ы
  Map<String, sxl.Sprite> sidePoints;  // Точки по сторонам для ресайза
  bool _draggable = false;
  bool _dragging = false;
  PhotoCut(this.x, this.y, this.width, this.height, {
      // Optional kwargs
      int color: sxl.Color.Red, sxl.Stage stage
  }) {
    _subscriptions = _emptySubscriptions;
    sidePoints = _emptySidePoints;
    shape = new sxl.Shape()..graphics.rect(x, y, width, height)
                           ..graphics.fillColor(color);
    sprite = new sxl.Sprite()..addChild(shape);
    if (stage != null) {
      bindToStage(stage);
    }
  }

  Map<String, Map<String, sxl.EventStreamSubscription>> get _emptySubscriptions => {
    'dragging': {},
    'resizing': {},
  };
  Map<String, sxl.Sprite> get _emptySidePoints {
    return {};
  }

  void drawSidePoints() {
    sidePoints = {
      'leftTop': new sxl.Sprite()..addChild(
          new sxl.Shape()..graphics.circle(x, y, 5)
                         ..graphics.fillColor(sxl.Color.LightPink)
      ),
      'rightTop': new sxl.Sprite()..addChild(
          new sxl.Shape()..graphics.circle(x + width, y, 5)
                         ..graphics.fillColor(sxl.Color.LightPink)
      ),
      'leftBottom': new sxl.Sprite()..addChild(
          new sxl.Shape()..graphics.circle(x, y + height, 5)
                         ..graphics.fillColor(sxl.Color.LightPink)
      ),
      'rightBottom': new sxl.Sprite()..addChild(
          new sxl.Shape()..graphics.circle(x + width, y + height, 5)
                         ..graphics.fillColor(sxl.Color.LightPink)
      ),
    };
    sidePoints.forEach((name, point) {
      bool pointClicked = false;
      _subscriptions['resizing']['${capFirst(name)}-down'] = point.onMouseDown.listen((evt) {
        pointClicked = true;
        point.startDrag(false);
        _subscriptions['resizing']['${capFirst(name)}-move'];//.pause();
        print('${capFirst(name)}-down');
        print(evt);
        print(pointClicked);
      });
      _subscriptions['resizing']['${capFirst(name)}-up'] = point.onMouseUp.listen((evt) {
        pointClicked = false;
        point.stopDrag();
        _subscriptions['resizing']['${capFirst(name)}-move'];//.resume();
        print('${capFirst(name)}-up');
        print(evt);
        print(pointClicked);
      });
      _subscriptions['resizing']['${capFirst(name)}-move'] = sprite.onMouseMove.listen((evt) {
        if (pointClicked) {
          if (name == 'rightBottom') {
            this.width = (shape.width = math.max(evt.stageX - x, 10));
            this.height = (shape.height = math.max(evt.stageY - y, 10));
          } else {
            throw new UnimplementedError("Not ready yet");
          }

          print([
              'this', x, y, width, height,
              'stage', stage.x, stage.y, stage.width.round(), stage.height.round(),
              'shape', shape.x, shape.y, shape.width.round(), shape.height.round(),
              'sprite', sprite.x, sprite.y, sprite.width.round(), sprite.height.round(),
              'bounds', sprite.bounds.left.round(), sprite.bounds.top.round(), sprite.bounds.right.round(), sprite.bounds.bottom.round(), sprite.bounds.width.round(), sprite.bounds.height.round(),
          ]);
        }
      });//..pause();
    });
    sidePoints.values.forEach((point) => sprite.addChild(point));
  }

  void bindToStage(sxl.Stage stage) {
    if (this.stage == null || this.stage != stage) {
      unbindEvents();
      this.stage = stage;
      stage.addChild(sprite);
      bindEvents();
    }
  }

  void unbindEvents () {
    _subscriptions.values.forEach((listeners) => listeners.values.forEach((sub) => sub.cancel()));
    _subscriptions = _emptySubscriptions;
  }

  void bindEvents() {
    _subscriptions['dragging'] = {
      'onMouseDown': sprite.onMouseDown.listen((sxl.Event event) {
        bool lockCenter = false;
        _dragging = true;
        sprite.startDrag(lockCenter);
      })..pause(),
      'onMouseUp': sprite.onMouseUp.listen((sxl.Event event) {
        _dragging = false;
        sprite.stopDrag();
      })..pause(),
    };
  }

  void set draggable(bool value) {
    if (stage == null) {
      throw new UnsupportedError("Must be bound to stage");
    }
    if (value && !_draggable) {
      _draggable = true;
      _subscriptions['dragging']['onMouseDown'].resume();
      _subscriptions['dragging']['onMouseUp'].resume();
    } else if (!value && _draggable) {
      _draggable = false;
      _subscriptions['dragging']['onMouseDown'].pause();
      _subscriptions['dragging']['onMouseUp'].pause();
    }
  }
  bool get draggable => _draggable;
}


void main() {
//  html.Element canvas = html.querySelector('#stage');
//  var stage = new sxl.Stage(canvas);
//  var renderLoop = new sxl.RenderLoop()..addStage(stage);
//  var cut = new PhotoCut(50, 50, 100, 100, stage: stage);
//  cut.draggable = false;
//
//  cut.drawSidePoints();
//
//  // var btn = new sxl.Shape()
//  //       ..graphics.rectRound(700, 0, 100, 50, 3, 3)
//  //       ..graphics.fillColor(sxl.Color.LightCoral);
//  // var button = new sxl.SimpleButton(btn)..addTo(btn);
//  // btn.onMouseClick.listen((evt) {
//  //   cut.draggable = !cut.dragable;
//  // });
//
//  var color = sxl.Color.Red;
  var canvas = html.querySelector('#stage');
  var stage = new sxl.Stage(canvas);
  var renderLoop = new sxl.RenderLoop()..addStage(stage);
  var shape = new sxl.Shape()
    ..graphics.rect(50, 50, 200, 100)
    ..graphics.fillColor(sxl.Color.DarkGray);
  stage.addChild(shape);

  stage.onMouseClick.listen((evt) {
    shape.width += 10;
    print('shape.width += 10;');
    print("SHAPE: x=${shape.x}, y=${shape.y}, w=${shape.width.round()}, h=${shape.height.round()}");
    print("STAGE: x=${stage.x}, y=${stage.y}, w=${stage.width.round()}, h=${stage.height.round()}");
  });

  stage.onMouseRightClick.listen((evt) {
    shape.width = math.max(shape.width - 10, 50);
    print('shape.width -= 10;');
    print("SHAPE: x=${shape.x}, y=${shape.y}, w=${shape.width.round()}, h=${shape.height.round()}");
    print("STAGE: x=${stage.x}, y=${stage.y}, w=${stage.width.round()}, h=${stage.height.round()}");
  });

  // var timer = new async.Timer.periodic(const Duration(seconds: 5), (self) {
  //   color = (color == sxl.Color.Red) ? sxl.Color.RosyBrown : sxl.Color.Red;
  //   cut..shape.graphics.fillColor(color)..draggable = !cut.draggable;
  //   print("TADA! I'm $self");
  // });

}