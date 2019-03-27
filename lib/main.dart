import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cams;
double r;

Future<void> main() async {
  cams = await availableCameras();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(_) {
    return MaterialApp(
      theme: ThemeData(iconTheme: IconThemeData(color: Colors.white)),
      home: MPg(),
    );
  }
}

class MPg extends StatefulWidget {
  MPg({Key key}) : super(key: key);
  @override
  _MPgState createState() => _MPgState();
}

class _MPgState extends State<MPg> with TickerProviderStateMixin {
  CameraController contr;
  double w;
  var tl = List<int>.generate(16, (i) => i)..shuffle();
  int step = 0;

  var tw = List<Tween>();
  var an = List<Animation>();
  var anct = List<AnimationController>();

  @override
  void initState() {
    super.initState();
    contr = CameraController(cams[1], ResolutionPreset.medium);
    contr.initialize().then((_) {
      if (!mounted) {
        return;
      }
      w = MediaQuery.of(context).size.width;
      r = 1 / contr.value.aspectRatio;
      step = 0;
      setState(() {});
    });
    for (int i = 0; i < 16; i++) {
      anct.add(AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 70),
      ));
      tw.add(Tween<Offset>(begin: Offset.zero, end: Offset(0, 1)));
      an.add(tw[i].animate(anct[i]));
      an[i].addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            anct[i].reset();
            step = 1;
            checkEnd();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    contr?.dispose();
    super.dispose();
  }

  void checkEnd() async {
    bool s = true;
    for (int i = 1; i < tl.length; i++) {
      if (tl[i - 1] < tl[i]) continue;
      s = false;
      break;
    }
    if (s)
      setState(() {
        step = 2;
      });
  }

  @override
  Widget build(context) {
    if (!contr.value.isInitialized) return Container();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GridView.builder(
              itemCount: 16,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1 / r,
              ),
              itemBuilder: (c, i) {
                return tile(tl[i]);
              },
            ),
          ),
          Container(
              padding: EdgeInsetsDirectional.only(bottom: 25), child: btmBar())
        ],
      ),
    );
  }

  Widget btmBar() {
    if (step == 0) {
      return Text(
        "Solve the jigsaw by swiping the tiles\n",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 25),
      );
    } else if (step == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
            ),
            iconSize: 50,
            onPressed: () {
              setState(() {
                tl.shuffle();
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.help_outline,
            ),
            iconSize: 50,
            onPressed: () {
              setState(() {
                step = 0;
              });
            },
          )
        ],
      );
    } else if (step == 2) {
      return Text(
        ":D Congrats :D\n",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 25),
      );
    }
    return Container();
  }

  void onDragEnd(d, i, swap) {
    if (d.primaryVelocity > 0)
      swap *= 1;
    else
      swap *= -1;
    try {
      int idx = tl.indexOf(i);
      tl[idx] = tl[idx + swap];
      tl[idx + swap] = i;

      if (swap == 1 || swap == -1) {
        tw[idx].end = Offset(swap / 1, 0);
        anct[idx].forward();
        tw[idx + swap].end = Offset(-swap / 1, 0);
        anct[idx + swap].forward();
      } else if (swap == 4 || swap == -4) {
        tw[idx].end = Offset(0, swap / 4);
        anct[idx].forward();
        tw[idx + swap].end = Offset(0, -swap / 4);
        anct[idx + swap].forward();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Widget tile(int i) {
    return SlideTransition(
      position: an[tl.indexOf(i)],
      child: GestureDetector(
        onVerticalDragEnd: (d) {
          onDragEnd(d, i, 4);
        },
        onHorizontalDragEnd: (d) {
          onDragEnd(d, i, 1);
        },
        child: OverflowBox(
          alignment: Alignment((-1 + 2 * ((i % 4) / 3).toDouble()),
              (-1 + 2 * ((i ~/ 4) / 3)).toDouble()),
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: Container(
            width: w,
            height: w * r,
            child: ClipRect(
              clipper: MClip(i, w / 4),
              child: CameraPreview(contr),
            ),
          ),
        ),
      ),
    );
  }
}

class MClip extends CustomClipper<Rect> {
  var w;
  int i;

  MClip(this.i, this.w);

  @override
  bool shouldReclip(_) => true;

  @override
  Rect getClip(_) => Rect.fromLTWH((i % 4) * w, (i ~/ 4) * w * r, w, w * r);
}
