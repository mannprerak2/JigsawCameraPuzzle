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
      theme: ThemeData(
          primarySwatch: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white)),
      home: MPage(),
    );
  }
}

class MPage extends StatefulWidget {
  MPage({Key key}) : super(key: key);
  @override
  _MPageState createState() => _MPageState();
}

class _MPageState extends State<MPage> {
  CameraController contr;
  double w;
  var tiles = List<int>.generate(16, (i) => i)..shuffle();
  int step = 0;

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
      tutOver();
      setState(() {});
    });
  }

  void tutOver() async {
    await Future.delayed(Duration(seconds: 4));
    step = 1;
    setState(() {});
  }

  @override
  void dispose() {
    contr?.dispose();
    super.dispose();
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
                return tile(tiles[i]);
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
        "Oops... The camera is broken\n Fix it by swiping on tiles\n",
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
                tiles.shuffle();
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
                tutOver();
              });
            },
          )
        ],
      );
    }
    return Container();
  }

  Widget tile(int i) {
    return GestureDetector(
      onVerticalDragEnd: (DragEndDetails d) {
        int swap;
        if (d.primaryVelocity > 0)
          swap = 4;
        else
          swap = -4;

        try {
          int idx = tiles.indexOf(i);
          tiles[idx] = tiles[idx + swap];
          tiles[idx + swap] = i;

          setState(() {});
        } catch (e) {
          print(e.toString());
        }
      },
      onHorizontalDragEnd: (DragEndDetails d) {
        int swap;
        if (d.primaryVelocity > 0)
          swap = 1;
        else
          swap = -1;
        print(swap);

        try {
          int idx = tiles.indexOf(i);
          tiles[idx] = tiles[idx + swap];
          tiles[idx + swap] = i;

          setState(() {});
        } catch (e) {
          print(e.toString());
        }
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
    );
  }
}

class MClip extends CustomClipper<Rect> {
  double w;
  int i;

  MClip(this.i, this.w);

  @override
  bool shouldReclip(_) => true;

  @override
  Rect getClip(_) => Rect.fromLTWH((i % 4) * w, (i ~/ 4) * w * r, w, w * r);
}
