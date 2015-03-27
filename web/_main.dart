import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

void main() {

  // setup the Stage and RenderLoop
  var canvas = html.querySelector('#stage');
  var stage = new Stage(canvas);
  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);
  
  // draw a red circle
  var shape = new Shape();
  shape.graphics.circle(100, 100, 60);
  shape.graphics.fillColor(Color.Red);
  
  
  Sprite sprite = new Sprite();
  sprite.addChild(shape);
  stage.addChild(sprite);
  
  sprite.onMouseDown.listen(mouseDownHandler);
  sprite.onMouseUp.listen(mouseUpHandler);
  
  
  
}


Sprite _target = new Sprite();
bool _dragging = false;

void mouseDownHandler(MouseEvent me) {
      _target = me.target as Sprite;
      //mouseOutX prevents puzzlepiece not returning to its place when leaving the stage
        _dragging = true;
        //set the target on the image that lies on top
        //_imageLayer.setChildIndex(_target, _imageLayer.numChildren - 1);
        //showLastClickedImageInfo(_target.name);
        //Rectangle rect = new Rectangle(0, 0, _imageBoxWidth, _imageBoxHeight);
        _target.startDrag(false);
   }

    void mouseUpHandler(MouseEvent me) {
      if (_dragging) {
        _dragging = false;
        _target.stopDrag();
      }
    }