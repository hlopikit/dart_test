import 'dart:html' as html;
import 'dart:async' as async;
import 'dart:math' as math;
import 'package:stagexl/stagexl.dart' as sxl;


class Container extends sxl.DisplayObjectContainer {
  sxl.Sprite sprite;
  sxl.Shape shape;
  sxl.Shape dotRBShape;
  sxl.Sprite dotRBSprite;
  sxl.Shape dotLBShape;
  sxl.Sprite dotLBSprite;
  sxl.Shape dotTLShape;
  sxl.Sprite dotTLSprite;
  sxl.Rectangle originalBox;
  sxl.Rectangle currentBox;
  bool _resizing = false;
  String _resizingSide;
  Container(x, y, w, h) {
    shape = new sxl.Shape()
      ..graphics.rect(x, y, w, h)
      ..graphics.fillColor(sxl.Color.DarkOliveGreen);
    originalBox = new sxl.Rectangle(x, y, w, h);
    currentBox = new sxl.Rectangle.from(originalBox);
    sprite = new sxl.Sprite()..addChild(shape);
    addChild(sprite);
    drawDots();
  }
  void drawDots() {
    dotRBShape = new sxl.Shape()
       ..graphics.circle(originalBox.right, originalBox.bottom, 15)
       ..graphics.fillColor(sxl.Color.Red);
    dotRBSprite = new sxl.Sprite()..addChild(dotRBShape);

    dotRBSprite
      ..onMouseDown.listen((evt) {
        dotRBSprite.startDrag();
        _resizing = true;
        _resizingSide = 'RB';
      })
      ..onMouseUp.listen((evt) {
        dotRBSprite.stopDrag();
        _resizing = false;
        _resizingSide = null;
      });

    addChild(dotRBSprite);


    dotLBShape = new sxl.Shape()
       ..graphics.circle(originalBox.left, originalBox.bottom, 15)
       ..graphics.fillColor(sxl.Color.DarkRed);
    dotLBSprite = new sxl.Sprite()..addChild(dotLBShape);

    dotLBSprite
      ..onMouseDown.listen((evt) {
        dotLBSprite.startDrag();
        _resizing = true;
        _resizingSide = 'LB';
      })
      ..onMouseUp.listen((evt) {
        dotLBSprite.stopDrag();
        _resizing = false;
        _resizingSide = null;
      });

    addChild(dotLBSprite);


    dotTLShape = new sxl.Shape()
       ..graphics.circle(originalBox.left, originalBox.top, 15)
       ..graphics.fillColor(sxl.Color.DarkOrange);
    dotTLSprite = new sxl.Sprite()..addChild(dotTLShape);

    dotTLSprite
      ..onMouseDown.listen((evt) {
        dotTLSprite.startDrag();
        _resizing = true;
        _resizingSide = 'TL';
      })
      ..onMouseUp.listen((evt) {
        dotTLSprite.stopDrag();
        _resizing = false;
        _resizingSide = null;
      });

    addChild(dotTLSprite);

    onMouseMove.listen((evt) {
      if (_resizing) {
        if (_resizingSide == 'RB') {
          currentBox.width = originalBox.width - dotLBSprite.x + dotRBSprite.x;
          currentBox.height = originalBox.height + dotRBSprite.y;
          shape
           ..graphics.clear()
           ..graphics.rect(currentBox.left, currentBox.top, currentBox.width, currentBox.height)
           ..graphics.fillColor(sxl.Color.DarkOliveGreen);
          dotLBSprite.y = dotRBSprite.y;
        } else if (_resizingSide == 'LB') {
          currentBox.width = currentBox.right - (originalBox.left + dotLBSprite.x);
          currentBox.left = originalBox.left + dotLBSprite.x;
          currentBox.height = originalBox.height + dotLBSprite.y;
          dotRBSprite.y = dotLBSprite.y;
          dotTLSprite.x = dotLBSprite.x;
        } else if (_resizingSide == 'TL') {
          currentBox.width = currentBox.right - (originalBox.left + dotTLSprite.x);
          currentBox.left = originalBox.left + dotTLSprite.x;
          currentBox.height = currentBox.bottom - (originalBox.top + dotTLSprite.y);
          currentBox.top = originalBox.top + dotTLSprite.y;
          dotLBSprite.x = dotTLSprite.x;
        }
        shape
         ..graphics.clear()
         ..graphics.rect(currentBox.left, currentBox.top, currentBox.width, currentBox.height)
         ..graphics.fillColor(sxl.Color.DarkOliveGreen);
      }
    });
  }
}

void main() {
  var canvas = html.querySelector('#stage');
  var stage = new sxl.Stage(canvas);
  var renderLoop = new sxl.RenderLoop()..addStage(stage);

  var container = new Container(50, 50, 200, 100);
  stage.addChild(container);
}