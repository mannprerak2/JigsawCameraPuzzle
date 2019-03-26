import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

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

    return buildPiece(2);

    // return GridView.builder(
    //   itemCount: 16,
    //   gridDelegate:
    //       SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
    //   itemBuilder: (context, i) {
    //     return buildPiece(0);
    //   },
    // );
  }

  Container buildPiece(int i) {
    return Container(
      child: ClipRect(
          clipper: RectClipper(i, width / 4),
          child: CameraPreview(controller)),
    );
  }

  // Container buildPiece(int i) {
  //   return Container(
  //     child: OverflowBox(
  //       maxWidth: width / 4,
  //       maxHeight: width / 4,
  //       alignment: FractionalOffset((i % 4) * width / 4, (i ~/ 4) * width / 4),
  //       child: ClipRect(
  //         clipper: RectClipper(i, width / 4),
  //         child: Container(
  //             child: AspectRatio(
  //                 aspectRatio: 3 / 4, child: CameraPreview(controller))),
  //       ),
  //     ),
  //   );
  // }
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
