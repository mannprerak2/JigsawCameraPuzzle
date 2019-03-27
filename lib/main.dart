import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';

List<CameraDescription> cameras;

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
      ),
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

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[1], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      width = MediaQuery.of(context).size.width;
      setState(() {});
    });
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
      body: Column(
        children: <Widget>[
          Expanded(
            child: GridView.builder(
              itemCount: 16,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemBuilder: (context, i) {
                return buildPiece(blocks[i]);
              },
            ),
          ),
          Text(
            "Help! the Camera is broken, Can you fix it?\nSwipe on tiles to interchange them\n",
          )
        ],
      ),
    );
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
          height: width,
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
    Rect rect = Rect.fromLTWH((i % 4) * w, (i ~/ 4) * w, w, w);
    return rect;
  }
}
