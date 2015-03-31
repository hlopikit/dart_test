import 'dart:html' as html;
import 'dart:async' as async;
import 'dart:math' as math;
import 'package:stagexl/stagexl.dart' as sxl;


num degToRad(num deg) => deg * (math.PI / 180.0);
num radToDeg(num rad) => rad * (180.0 / math.PI);

sxl.Point<int> rotatePoint(sxl.Point center, double angle, sxl.Point p) {
  // http://stackoverflow.com/questions/2259476/
  double s = math.sin(-angle);
  double c = math.cos(-angle);

  // translate point back to origin:
  double x = p.x - center.x;
  double y = p.y - center.y;

  // rotate point
  double newX = x * c - y * s;
  double newY = x * s + y * c;

  // translate point back:
  return new sxl.Point<int>((newX + center.x).round(), (newY + center.y).round());
}


class Cut extends sxl.DisplayObjectContainer {
  sxl.Rectangle<int> box;
  int bgColor = sxl.Color.YellowGreen;
  sxl.Shape bg;
  sxl.Shape borders;
  double _angle = 0.0;
  bool _bordersShown = false;
  sxl.Bitmap pic;

  void rotateAroundCenter(num angle) {
    transformationMatrix.translate(
      -(bounds.left + (bounds.width / 2)),
      -(bounds.top + (bounds.height / 2))
    );
    transformationMatrix.rotate(degToRad(angle));
    transformationMatrix.translate(
      bounds.left + (bounds.width / 2),
      bounds.top + (bounds.height / 2)
    );
  }

  Cut(this.box) {
    drawBg();
    drawBorders();


    onMouseClick.listen((e) {
      resize(box.width + 5, box.height + 5);
    });
    onMouseRightClick.listen((e) {
      resize(box.width - 5, box.height - 5);
    });

    new async.Timer.periodic(const Duration(seconds: 1), (self) {
      angle += 1.0;
      rotateAroundCenter(angle);
      print([borders.x.round(), borders.y.round(), borders.width.round(), borders.height.round(), borders.rotation]);
    });

    // addPic(html.querySelector('#im'));
  }

  double get angle => _angle;
  void set angle(num a) {
    _angle = a.remainder(360);
    // if (bordersShown) {
    //   drawBorders();
    // }
    // drawBg();
  }

  addPic(html.ImageElement el) {
    if (pic != null) {
      removeChild(pic);
    }
    var bitmapData = new sxl.BitmapData.fromImageElement(el);
    pic = new sxl.Bitmap(bitmapData);
    pic.x = box.left;
    pic.y = box.top;
    addChild(pic);
  }
  void redrawPic() {
    pic.transformationMatrix.rotate(degToRad(2));
  }

  List<sxl.Point<int>> getPoints() {
    if (angle == 0) {
      return [box.topLeft, box.topRight, box.bottomRight, box.bottomLeft];
    }
    double a = degToRad(angle);
    return [
        box.topLeft,
        rotatePoint(box.topLeft, a, box.topRight),
        rotatePoint(box.topLeft, a, box.bottomRight),
        rotatePoint(box.topLeft, a, box.bottomLeft),
    ];
  }

  void drawBg() {
    var points = getPoints();
    bool isNew;
    if (bg == null) {
      bg = new sxl.Shape();
      isNew = true;
    } else {
      bg.graphics.clear();
      isNew = false;
    }
    if (points.length > 1) {
      bg.graphics.moveTo(points[0].x, points[0].y);
      points.getRange(1, points.length).forEach((p) {
        bg.graphics.lineTo(p.x, p.y);
      });
      bg.graphics.lineTo(points[0].x, points[0].y);
      bg.graphics.fillColor(bgColor);
    }
    ;
    addChildAt(bg, 0);
  }

  void drawBorders() {
    var points = getPoints();
    bool isNew;
    if (borders == null) {
      borders = new sxl.Shape();
      isNew = true;
    } else {
      borders.graphics.clear();
      isNew = false;
    }
    if (points.length > 1) {
      borders.graphics.moveTo(points[0].x, points[0].y);
      points.getRange(1, points.length).forEach((p) {
        borders.graphics.lineTo(p.x, p.y);
      });
      borders
        ..graphics.lineTo(points[0].x, points[0].y)
        ..graphics.strokeColor(sxl.Color.Red);
    }
    if (isNew) {
      addChild(borders);
    }
    _bordersShown = true;
  }
  void removeBorders() {
    removeChild(borders);
    borders = null;
    _bordersShown = false;
  }

  bool get bordersShown => _bordersShown;
  void set bordersShown(bool show) {
    if (show) {
      if (!_bordersShown) {
        drawBorders();
      }
    } else {
      if (_bordersShown) {
        removeBorders();
      }
    }
  }

  void resize(width, height) {
    box.width = width;
    box.height = height;
    borders.width = width;
    borders.height = height;
    bg.width = width;
    bg.height = height;
    print('${borders.graphics.x}');
  }
}


class Container extends sxl.DisplayObjectContainer {
  List<Cut> cuts = [];

  Container() {
    addChild(new sxl.Shape()
      ..graphics.rect(0, 0, 800, 600)
      ..graphics.fillColor(sxl.Color.Transparent));

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

  void addCut([sxl.Rectangle box]) {
    if (box == null) {
      box = new sxl.Rectangle(100, 100, 100, 100);
    }

    var cut = new Cut(box);
    addChild(cut);
    cuts.add(cut);
  }


}






void main() {
  var canvas = html.querySelector('#stage');
  var stage = new sxl.Stage(canvas);
  var renderLoop = new sxl.RenderLoop()..addStage(stage);

  var container = new Container();
  stage.addChild(container);

  // for (int i=100; i>0; i-=10) {
  //   container.addCut(new sxl.Rectangle(200, 200, i, i));
  // }

  html.querySelector('#FOO').onClick.listen((e) {

    for (int i=0; i<1; ++i) {
      container.addCut(new sxl.Rectangle(
          new math.Random().nextInt(500),
          new math.Random().nextInt(500),
          new math.Random().nextInt(500),
          new math.Random().nextInt(500)
      ));
      container.cuts.last.bgColor = [
          0xFFF0F8FF,
          0xFFFAEBD7,
          0xFF00FFFF,
          0xFF7FFFD4,
          0xFFF0FFFF,
          0xFFF5F5DC,
          0xFFFFE4C4,
          0xFF000000,
          0xFFFFEBCD,
          0xFF0000FF,
          0xFF8A2BE2,
          0xFFA52A2A,
          0xFFDEB887,
          0xFF5F9EA0,
          0xFF7FFF00,
          0xFFD2691E,
          0xFFFF7F50,
          0xFF6495ED,
          0xFFFFF8DC,
          0xFFDC143C,
          0xFF00FFFF,
          0xFF00008B,
          0xFF008B8B,
          0xFFB8860B,
          0xFFA9A9A9,
          0xFF006400,
          0xFFBDB76B,
          0xFF8B008B,
          0xFF556B2F,
          0xFFFF8C00,
          0xFF9932CC,
          0xFF8B0000,
          0xFFE9967A,
          0xFF8FBC8B,
          0xFF483D8B,
          0xFF2F4F4F,
          0xFF00CED1,
          0xFF9400D3,
          0xFFFF1493,
          0xFF00BFFF,
          0xFF696969,
          0xFF1E90FF,
          0xFFB22222,
          0xFFFFFAF0,
          0xFF228B22,
          0xFFFF00FF,
          0xFFDCDCDC,
          0xFFF8F8FF,
          0xFFFFD700,
          0xFFDAA520,
          0xFF808080,
          0xFF008000,
          0xFFADFF2F,
          0xFFF0FFF0,
          0xFFFF69B4,
          0xFFCD5C5C,
          0xFF4B0082,
          0xFFFFFFF0,
          0xFFF0E68C,
          0xFFE6E6FA,
          0xFFFFF0F5,
          0xFF7CFC00,
          0xFFFFFACD,
          0xFFADD8E6,
          0xFFF08080,
          0xFFE0FFFF,
          0xFFFAFAD2,
          0xFFD3D3D3,
          0xFF90EE90,
          0xFFFFB6C1,
          0xFFFFA07A,
          0xFF20B2AA,
          0xFF87CEFA,
          0xFF778899,
          0xFFB0C4DE,
          0xFFFFFFE0,
          0xFF00FF00,
          0xFF32CD32,
          0xFFFAF0E6,
          0xFFFF00FF,
          0xFF800000,
          0xFF66CDAA,
          0xFF0000CD,
          0xFFBA55D3,
          0xFF9370DB,
          0xFF3CB371,
          0xFF7B68EE,
          0xFF00FA9A,
          0xFF48D1CC,
          0xFFC71585,
          0xFF191970,
          0xFFF5FFFA,
          0xFFFFE4E1,
          0xFFFFE4B5,
          0xFFFFDEAD,
          0xFF000080,
          0xFFFDF5E6,
          0xFF808000,
          0xFF6B8E23,
          0xFFFFA500,
          0xFFFF4500,
          0xFFDA70D6,
          0xFFEEE8AA,
          0xFF98FB98,
          0xFFAFEEEE,
          0xFFDB7093,
          0xFFFFEFD5,
          0xFFFFDAB9,
          0xFFCD853F,
          0xFFFFC0CB,
          0xFFDDA0DD,
          0xFFB0E0E6,
          0xFF800080,
          0xFFFF0000,
          0xFFBC8F8F,
          0xFF4169E1,
          0xFF8B4513,
          0xFFFA8072,
          0xFFF4A460,
          0xFF2E8B57,
          0xFFFFF5EE,
          0xFFA0522D,
          0xFFC0C0C0,
          0xFF87CEEB,
          0xFF6A5ACD,
          0xFF708090,
          0xFFFFFAFA,
          0xFF00FF7F,
          0xFF4682B4,
          0xFFD2B48C,
          0xFF008080,
          0xFFD8BFD8,
          0xFFFF6347,
          0x00FFFFFF,
          0xFF40E0D0,
          0xFFEE82EE,
          0xFFF5DEB3,
          0xFFFFFFFF,
          0xFFF5F5F5,
          0xFFFFFF00,
          0xFF9ACD32
      ][new math.Random().nextInt(141)];
    }
  });


  container.addChild(
    new sxl.SimpleButton(new sxl.Sprite()
      ..addChild(
        new sxl.Shape()
          ..graphics.rect(700, 550, 100, 50)
          ..graphics.fillColor(sxl.Color.Black)
      )
      ..addChild(
        new sxl.TextField()
          ..text = 'Тест'
          ..mouseEnabled = false
          ..textColor = sxl.Color.WhiteSmoke
          ..x = 700
          ..y = 550
      )
    )..onMouseClick.listen((e) {
      print(e);
    })
  );
}