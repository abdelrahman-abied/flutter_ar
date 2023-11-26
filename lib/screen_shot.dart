import 'dart:io';

import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class ScreenshotWidget extends StatefulWidget {
  const ScreenshotWidget({Key? key}) : super(key: key);
  @override
  _ScreenshotWidgetState createState() => _ScreenshotWidgetState();
}

class ArObjectModel {
  final String name;
  final String path;
  final String url;
  final String androidUrl;
  ArObjectModel({
    required this.name,
    required this.path,
    required this.url,
    required this.androidUrl,
  });
}

class _ScreenshotWidgetState extends State<ScreenshotWidget> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];

  @override
  void dispose() {
    super.dispose();
    arSessionManager!.dispose();
  }

  List<ArObjectModel> arObjects = [
    ArObjectModel(
      name: "450l",
      path: "assets/pictures/images/ver_tank.png",
      url:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/Tank_450L.glb?raw=true§",
      androidUrl:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/android_tank_450L.glb?raw=true§",
    ),
    ArObjectModel(
      name: "1000L",
      path: "assets/pictures/images/hor_tank.png",
      url:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/tank_1000L.glb?raw=true",
      androidUrl:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/android_tank_1000L.glb?raw=true",
    ),
    ArObjectModel(
      name: "2000L",
      path: "assets/pictures/images/hor_tank.png",
      url:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/tank_2000L.glb?raw=true",
      androidUrl:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/android_tank_2000L.glb?raw=true",
    ),
    ArObjectModel(
      name: "4000L",
      path: "assets/pictures/images/hor_tank.png",
      url:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/tank_4000L.glb?raw=true",
      androidUrl:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/android_tank_4000L.glb?raw=true",
    ),
    ArObjectModel(
      name: "7000L",
      path: "assets/pictures/images/hor_tank.png",
      url:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/tank_7000L.glb?raw=true",
      androidUrl:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/android_tank_7000L.glb?raw=true",
    ),
  ];
  int selectedImage = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Screenshots'),
        ),
        body: Container(
            child: Stack(children: [
          GestureDetector(
            // onScaleUpdate: (details) {
            //   nodes.first.transform = Matrix4.identity()..scale(details.scale);
            // },
            child: ARView(
              onARViewCreated: onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontal,
              // showPlatformType: true,
            ),
          ),
          // Align(
          //   alignment: Alignment.center,
          //   child: Text(
          //     nodes.first.scale.toString(),
          //   ),
          // ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: arObjects
                      .map((e) => Expanded(
                            child: InkWell(
                              onTap: () {
                                onRemoveEverything();
                                selectedImage = arObjects.indexOf(e);
                                setState(() {});
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selectedImage == arObjects.indexOf(e)
                                        ? Colors.grey
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        e.path,
                                        width: 50,
                                        height: 50,
                                      ),
                                      AutoSizeText(
                                        e.name,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: onRemoveEverything, child: const Text("Remove Everything"))),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: onTakeScreenshot, child: const Text("Take Screenshot"))),
                  Expanded(
                    child: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          debugPrint("scale: ${nodes.first.scale}");
                          debugPrint("scale: ${nodes.length}");

                          nodes.last.transform = Matrix4.identity()..scale(nodes.last.scale * 2);
                        },
                        icon: const Icon(Icons.add)),
                  ),
                  Expanded(
                    child: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          debugPrint("scale: ${nodes.first.scale}");
                          debugPrint("scale: ${nodes.length}");
                          nodes.first.transform = Matrix4.identity()..scale(nodes.last.scale * .5);
                        },
                        icon: const Icon(Icons.minimize)),
                  )
                ]),
              ],
            ),
          )
        ])));
  }

  void onARViewCreated(ARSessionManager arSessionManager, ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager, ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager!.onInitialize(
          showFeaturePoints: false,
          showPlanes: true,
          // customPlaneTexturePath: "Images/triangle.png",
          showWorldOrigin: false,
          customPlaneTexturePath: "Images/triangle.png",
          handlePans: true,
          handleRotation: true,
        );
    this.arObjectManager!.onInitialize();

    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arObjectManager!.onPanStart = onPanStarted;
    this.arObjectManager!.onPanChange = onPanChanged;
    this.arObjectManager!.onPanEnd = onPanEnded;
    this.arObjectManager!.onRotationStart = onRotationStarted;
    this.arObjectManager!.onRotationChange = onRotationChanged;
    this.arObjectManager!.onRotationEnd = onRotationEnded;
    this.arObjectManager!.onNodeTap = onNodeTapped;
  }

  Future<void> onRemoveEverything() async {
    nodes.forEach((node) {
      arObjectManager?.removeNode(node);
    });
    // anchors.forEach((anchor)
    for (var anchor in anchors) {
      arAnchorManager!.removeAnchor(anchor);
    }
    nodes.clear();
    nodes = [];
    anchors = [];
  }

  Future<void> onTakeScreenshot() async {
    var image = await arSessionManager!.snapshot();
    if (context.mounted) {
      await showDialog(
          context: context,
          builder: (_) => Dialog(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(image: DecorationImage(image: image, fit: BoxFit.fill)),
                ),
              ));
    }
  }

  Future<void> onNodeTapped(List<String> nodes) async {
    var number = nodes.length;
    // arSessionManager!.onError("Tapped $number node(s)");
    debugPrint("Tapped $number node(s)");
  }

  Future<void> onPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) async {
    var singleHitTestResult = hitTestResults
        .firstWhere((hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    var newAnchor = ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
    bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
    if (didAddAnchor != null && didAddAnchor) {
      if (anchors.isEmpty || anchors.length < 1) {
        anchors.add(newAnchor);
        // Add note to anchor
        var newNode = ARNode(
            type: NodeType.webGLB,
            // uri:
            // "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF-Binary/Duck.glb",
            // scale: Vector3(0.2, 0.2, 0.2),
            //  real worked worked
            // "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/simple_propane_tank.glb?raw=true",
            // worked
            // "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/tank_shell_1000l.glb?raw=true",
            // real worked worked
            // "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/tank_1000l.glb?raw=true",
            // not worked
            // "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/tank_4000l.glb?raw=true",
            // not worked
            // "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/tank_4000l_1.glb?raw=true",
            // not worked
            // "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/Tank_450_L.glb?raw=true",
            // real worked
            // "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/tank_1000l_Husam.glb?raw=true",
            // real worked worked
            // "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/abdelrahman.glb?raw=true",
            // real worked worked
            // "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/tank_1000lb.glb?raw=true",

            /// worked
            // "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/Tank_1000.glb?raw=true",
            // "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/Tank_2000.glb?raw=true",
            // "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/Tank_4000.glb?raw=true",
            uri:
                Platform.isIOS ? arObjects[selectedImage].url : arObjects[selectedImage].androidUrl,
            scale: Platform.isIOS ? Vector3(50, 50, 50) : Vector3(1, 1, 1),
            position: Vector3(0.0, 0.0, 0.0),
            rotation: Vector4(1.0, 0.0, 0.0, 0.0));

        bool? didAddNodeToAnchor = await arObjectManager!.addNode(newNode, planeAnchor: newAnchor);

        if (didAddNodeToAnchor != null && didAddNodeToAnchor) {
          nodes.add(newNode);
        } else {
          arSessionManager!.onError("Adding Node to Anchor failed");
        }
      }
    } else {
      arSessionManager?.onError("Adding Anchor failed");
    }
  }

  onPanStarted(String nodeName) {
    print("Started panning node " + nodeName);
  }

  onPanChanged(String nodeName) {
    print("Continued panning node " + nodeName);
  }

  onPanEnded(String nodeName, Matrix4 newTransform) {
    print("Ended panning node " + nodeName);
    // final pannedNode = nodes.firstWhere((element) => element.name == nodeName);

    /*
    * Uncomment the following command if you want to keep the transformations of the Flutter representations of the nodes up to date
    * (e.g. if you intend to share the nodes through the cloud)
    */
    //pannedNode.transform = newTransform;
  }

  onRotationStarted(String nodeName) {
    print("Started rotating node " + nodeName);
  }

  onRotationChanged(String nodeName) {
    print("Continued rotating node " + nodeName);
  }

  onRotationEnded(String nodeName, Matrix4 newTransform) {
    print("Ended rotating node " + nodeName);
    // final rotatedNode = nodes.firstWhere((element) => element.name == nodeName);

    /*
    * Uncomment the following command if you want to keep the transformations of the Flutter representations of the nodes up to date
    * (e.g. if you intend to share the nodes through the cloud)
    */
    //rotatedNode.transform = newTransform;
  }
}
