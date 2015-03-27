import 'dart:html' as html;
import 'dart:async' as async;
import 'dart:math' as math;
import 'package:stagexl/stagexl.dart' as sxl;


class Container extends sxl.DisplayObjectContainer {
  sxl.Sprite sprite;
  sxl.Shape shape;
  sxl.Shape dotShape;
  sxl.Circle dotBox;
  sxl.Sprite dotSprite;
  sxl.Rectangle currentBox;
  bool _resizing = false;
  Container(x, y, w, h) {
    shape = new sxl.Shape()
      ..graphics.rect(x, y, w, h)
      ..graphics.fillColor(sxl.Color.DarkOliveGreen);
    currentBox = new sxl.Rectangle(x, y, w, h);
    sprite = new sxl.Sprite()..addChild(shape);
    addChild(sprite);
    /*onMouseClick.listen((evt) {
       currentBox.width += 10;
       shape
         ..graphics.clear()
         ..graphics.rect(currentBox.left, currentBox.top, currentBox.width, currentBox.height)
         ..graphics.fillColor(sxl.Color.DarkOliveGreen);
       print("SHAPE: x=${shape.x}, y=${shape.y}, w=${shape.width.round()}, h=${shape.height.round()}");
       print("CONTAINER: x=${this.x}, y=${this.y}, w=${this.width.round()}, h=${this.height.round()}");
    });

    onMouseRightClick.listen((evt) {
       currentBox.width -= 10;
       shape
         ..graphics.clear()
         ..graphics.rect(currentBox.left, currentBox.top, currentBox.width, currentBox.height)
         ..graphics.fillColor(sxl.Color.DarkOliveGreen);
       print("SHAPE: x=${shape.x}, y=${shape.y}, w=${shape.width.round()}, h=${shape.height.round()}");
       print("CONTAINER: x=${this.x}, y=${this.y}, w=${this.width.round()}, h=${this.height.round()}");
    });*/
    drawDot();
  }
  void drawDot() {
    dotBox = new sxl.Circle(currentBox.right, currentBox.bottom, 5);
    dotShape = new sxl.Shape()
       ..graphics.circle(dotBox.x, dotBox.y, dotBox.radius)
       ..graphics.fillColor(sxl.Color.Red);
    onMouseClick.listen((evt) {
       print(evt.target);
    });
    dotSprite = new sxl.Sprite()..addChild(dotShape);

    dotSprite
      ..onMouseDown.listen((evt) {
        dotSprite.startDrag();
        _resizing = true;
      })
      ..onMouseUp.listen((evt) {
        dotSprite.stopDrag();
        _resizing = false;
      });

    onMouseMove.listen((evt) {
      if (_resizing) {
        currentBox.right = evt.stageX;
        currentBox.bottom = evt.stageY;
        shape
         ..graphics.clear()
         ..graphics.rect(currentBox.left, currentBox.top, currentBox.width, currentBox.height)
         ..graphics.fillColor(sxl.Color.DarkOliveGreen);
      }
    });

    addChild(dotSprite);
  }
}

void main() {
  var canvas = html.querySelector('#stage');
  var stage = new sxl.Stage(canvas);
  var renderLoop = new sxl.RenderLoop()..addStage(stage);

  var container = new Container(50, 50, 200, 100);
  stage.addChild(container);
}