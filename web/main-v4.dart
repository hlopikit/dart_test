import 'dart:html' as html;
import 'dart:async' as async;
import 'dart:math' as math;
import 'package:stagexl/stagexl.dart' as sxl;


num degToRad(num deg) => deg * (math.PI / 180.0);
num radToDeg(num rad) => rad * (180.0 / math.PI);


class InnerCut extends sxl.DisplayObjectContainer {
  sxl.Shape borders;
  sxl.Mask cutMask;
  int realWidth, realHeight;
  sxl.Bitmap pic;
  InnerCut(this.realWidth, this.realHeight) {
    drawBordersAndMask();
    // addPic(html.querySelector('#im'));
    addPicByUrl('images/touch/chrome-touch-icon-192x192.png');
    addPicByUrl('images/touch/chrome-touch-icon-192x192.png');
    addPicByUrl('images/touch/chrome-touch-icon-192x192.png');
    addPicByUrl('images/touch/chrome-touch-icon-192x192.png');
    addPicByUrl('images/touch/chrome-touch-icon-192x192.png');
    addPicByUrl('images/touch/chrome-touch-icon-192x192.png');
  }

  void drawBordersAndMask() {
    borders = new sxl.Shape();
    borders
      ..graphics.clear()
      ..graphics.moveTo(0, 0)
      ..graphics.lineTo(this.realWidth - 1, 0)
      ..graphics.lineTo(this.realWidth - 1, this.realHeight - 1)
      ..graphics.lineTo(0, this.realHeight - 1)
      ..graphics.lineTo(0, 0)
      ..graphics.strokeColor(sxl.Color.Black);
    addChild(borders);
    borders.visible = false;
    cutMask = new sxl.Mask.rectangle(-1, -1, realWidth + 1, realHeight + 1);
    mask = cutMask;
  }

  void addPicByUrl(String url) {
    var manager = new sxl.ResourceManager();
    manager.addBitmapData('picture', url);
    manager.load().then((self) {
      addPic(manager.getBitmapData('picture'));
    });
  }

  void addPic(sxl.BitmapData bitmapData) {
    if (pic != null) {
      removeChild(pic);
    }
    pic = new sxl.Bitmap(bitmapData);
    resizeToSide(pic, h: realHeight);
    pic.x = (realWidth / 2 - pic.width / 2).round();
    // pic.height = realHeight;
    print([realWidth, realHeight]);
    addChildAt(pic, 0);
  }

  static void resizeToSide(sxl.Bitmap obj, {int w: null, int h: null}) {
    double ratio;
    if (w == null && h == null) {
      throw new ArgumentError('provide width (w) or height (h)');
    } else if (w != null && h != null) {
      obj.width = w;
      obj.height = h;
    } else if (w != null) {
      ratio = w / obj.width;
      obj.width = w;
      obj.height = (obj.height * ratio).round();
    } else if (h != null) {
      ratio = h / obj.height;
      obj.width = (obj.width * ratio).round();
      obj.height = h;
    }
  }
}



class Cut extends sxl.DisplayObjectContainer {
  InnerCut _inner;
  num _angle = 0;
  int realWidth, realHeight;
  Cut(int realWidth, int realHeight) {
    if (realWidth < 1) {realWidth = 1;}
    if (realHeight < 1) {realHeight = 1;}
    this.realWidth = realWidth;
    this.realHeight = realHeight;
    this._inner = new InnerCut(this.realWidth, this.realHeight);
    addChild(_inner);
  }

  num get angle => _angle;
  void set angle(num a) {
    num diff = a - _angle;
    _angle = a;
    rotateAroundCenter(diff);
    print([_inner.borders.x, _inner.borders.y, _inner.borders.width, _inner.borders.height]);
  }
  void rotateAroundCenter(num angle) {
    _inner.transformationMatrix.translate(
        -(_inner.bounds.width / 2),
        -(_inner.bounds.height / 2)
    );
    _inner.transformationMatrix.rotate(degToRad(angle));
    _inner.transformationMatrix.translate(
        _inner.bounds.width / 2,
        _inner.bounds.height / 2
    );
  }

  bool get bordersShown => _inner.borders.visible;
  void set bordersShown(bool val) {_inner.borders.visible = val;}
}


class Container extends sxl.DisplayObjectContainer {
  void showFps() {
    num _fpsAverage = null;
    onEnterFrame.listen((e) {
      num newFpsAverage;
      if (_fpsAverage == null) {
        newFpsAverage = 1.00 / e.passedTime;
      } else {
        newFpsAverage = 0.05 / e.passedTime + 0.95 * _fpsAverage;
      }
      newFpsAverage = newFpsAverage.round();
      if (newFpsAverage != _fpsAverage) {
        html.querySelector('#fps').innerHtml = newFpsAverage.toString();
      }
      _fpsAverage = newFpsAverage;
    });
  }
  Container() {
    showFps();
    // Фокус пока такой :P
    onMouseClick.listen((sxl.MouseEvent e) {
      if (e.target != null && e.target is InnerCut) {
        stage.focus = e.target;
        e.target.parent.bordersShown = true;
      }
      for (int i=0; i<cuts.length; ++i) {
        var cut = cuts[i];
        if (cut != e.target.parent) {
          cut.bordersShown = false;
        }
      }
    });
  }
  List<Cut> cuts = [];
  void addCut([sxl.Rectangle box]) {
    if (box == null) {
      box = new sxl.Rectangle(100, 100, 100, 300);
    }

    var cut = new Cut(box.width, box.height);
    cut.x = box.left;
    cut.y = box.top;
    addChild(cut);
    cuts.add(cut);
  }


}



void main() {
  var canvas = html.querySelector('#stage');
  var stage = new sxl.Stage(canvas);
  var renderLoop = new sxl.RenderLoop()
    ..addStage(stage);

  var container = new Container();
  stage.addChild(container);

  container.addCut();

  // for (int i=100; i>0; i-=10) {
  //   container.addCut(new sxl.Rectangle(200, 200, i, i));
  // }

  html.querySelector('#FOO')
    ..onClick.listen((e) {
      for (int i = 0; i < 1; ++i) {
        container.addCut(
            new sxl.Rectangle(
                new math.Random().nextInt(500),
                new math.Random().nextInt(500),
                new math.Random().nextInt(500),
                new math.Random().nextInt(500)
            )
        );
      }
    })
    ..onMouseWheel.listen((html.WheelEvent e) {
        container.cuts.first.angle += e.deltaY / 20;
    });
}