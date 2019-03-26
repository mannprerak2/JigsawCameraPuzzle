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
    if (!controller.value.isInitialized) {
      return Container();
    }

    return buildPiece(1);

    return GridView.builder(
      itemCount: 16,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemBuilder: (context, i) {
        return buildPiece(i);
      },
    );
  }

  // SizedBox buildPiece(int i) {
  //   return SizedBox(
  //     width: 100,
  //     height: 100,
  //     child: Container(
  //       width: width,
  //       height: width,
  //       color: Colors.green,
  //       child: ClipRect(
  //           clipper: RectClipper(i, width / 4),
  //           child: CameraPreview(controller)),
  //     ),
  //   );
  // }

  Widget buildPiece(int i) {
    return Container(
      color: Colors.white,
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: width / 4,
          height: width / 4,
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.green)),
            width: width,
            height: width * 1.33,
            child: ClipRect(
              clipper: RectClipper(i, width / 4),
              child: CameraPreview(controller),
            ),
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
