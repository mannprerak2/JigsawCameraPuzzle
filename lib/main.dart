import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';

List<CameraDescription> cameras;
double ratio;

Future<void> main() async {
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jigsaw Cam',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white)),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CameraController controller;
  double width;
  List<int> blocks = List<int>.generate(16, (i) => i)..shuffle();
  int step = 0;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[1], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      width = MediaQuery.of(context).size.width;
      ratio = 1 / controller.value.aspectRatio;
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
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) return Container();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GridView.builder(
              itemCount: 16,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: (1 / ratio).toDouble(),
              ),
              itemBuilder: (context, i) {
                return buildPiece(blocks[i]);
              },
            ),
          ),
          Container(
              padding: EdgeInsetsDirectional.only(bottom: 25),
              child: buildBottomBar())
        ],
      ),
    );
  }

  Widget buildBottomBar() {
    if (step == 0) {
      return Text(
        "Oops... The camera is broken\n Fix it by swiping on tiles\n",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 20),
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
                blocks.shuffle();
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

  Widget buildPiece(int i) {
    return GestureDetector(
      onVerticalDragEnd: (DragEndDetails drag) {
        int swapWith;
        if (drag.primaryVelocity > 0)
          swapWith = 4;
        else
          swapWith = -4;
        print(swapWith);
        try {
          int index = blocks.indexOf(i);
          blocks[index] = blocks[index + swapWith];
          blocks[index + swapWith] = i;

          setState(() {});
        } catch (e) {}
      },
      onHorizontalDragEnd: (DragEndDetails drag) {
        int swapWith;
        if (drag.primaryVelocity > 0)
          swapWith = 1;
        else
          swapWith = -1;
        print(swapWith);

        try {
          int index = blocks.indexOf(i);
          blocks[index] = blocks[index + swapWith];
          blocks[index + swapWith] = i;

          setState(() {});
        } catch (e) {}
      },
      child: OverflowBox(
        alignment: Alignment((-1 + 2 * ((i % 4) / 3).toDouble()),
            (-1 + 2 * ((i ~/ 4) / 3)).toDouble()),
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Container(
          width: width,
          height: width * ratio,
          child: ClipRect(
            clipper: RectClipper(i, width / 4),
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}

class RectClipper extends CustomClipper<Rect> {
  double w;
  int i;

  RectClipper(this.i, this.w);

  @override
  bool shouldReclip(RectClipper oldClipper) => true;

  @override
  Rect getClip(Size size) {
    Rect rect = Rect.fromLTWH((i % 4) * w, (i ~/ 4) * w * ratio, w, w * ratio);
    return rect;
  }
}
