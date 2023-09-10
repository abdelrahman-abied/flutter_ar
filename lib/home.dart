// import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
// import 'package:ar_flutter_plugin/datatypes/node_types.dart';
// import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
// import 'package:ar_flutter_plugin/models/ar_node.dart';
// import 'package:flutter/material.dart';
// import 'package:vector_math/vector_math_64.dart';

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
// // ARView: Creates a platform-dependent camera view using PlatformARView
// // ARSessionManager: Manages the ARView’s session configuration, parameters, and events
// // ARObjectManager: Manages all node related actions of an ARView
// // ARAnchorManager: Manages anchor functionalities like download handler and upload handler
// // ARLocationManager: Provides ability to get and update current location of the device
// // ARNode: A model class for node objects
//   late ARSessionManager arSessionManager;
//   late ARObjectManager arObjectManager;
//   //String localObjectReference;
//   ARNode? localObjectNode;
//   //String webObjectReference;
//   ARNode? webObjectNode;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Expanded(
//             child: ARView(
//               onARViewCreated: onARViewCreated,
//             ),
//           ),
//           Row(
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   onLocalObjectButtonPressed();
//                 },
//                 child: const Text("Local Object"),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }

//   Future<void> onLocalObjectButtonPressed() async {
//     // 1
//     if (localObjectNode != null) {
//       arObjectManager.removeNode(localObjectNode!);
//       localObjectNode = null;
//     } else {
//       // 2
//       var newNode = ARNode(
//         type: NodeType.localGLTF2,
//         uri: "assets/images/gas_tank.gltf",
//         scale: Vector3(0.2, 0.2, 0.2),
//         position: Vector3(0.0, 0.0, 0.0),
//         rotation: Vector4(1.0, 0.0, 0.0, 0.0),
//       );
//       // 3
//       bool? didAddLocalNode = await arObjectManager.addNode(newNode);
//       localObjectNode = (didAddLocalNode!) ? newNode : null;
//     }
//   }

//   void onARViewCreated(
//     ARSessionManager arSessionManager,
//     ARObjectManager arObjectManager,
//     ARAnchorManager arAnchorManager,
//     ARLocationManager arLocationManager,
//   ) {
//     // 1
//     this.arSessionManager = arSessionManager;
//     this.arObjectManager = arObjectManager;
//     // 2
//     this.arSessionManager.onInitialize(
//           showFeaturePoints: false,
//           showPlanes: true,
//           customPlaneTexturePath: "assets/images/gas_tank.gltf",
//           showWorldOrigin: true,
//           handleTaps: false,
//         );
//     // 3
//     this.arObjectManager.onInitialize();
//   }

import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
//   @override
//   void dispose() {
//     arSessionManager.dispose();
//     super.dispose();
//   }
// }
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class ObjectGesturesWidget extends StatefulWidget {
  ObjectGesturesWidget({Key? key}) : super(key: key);
  @override
  _ObjectGesturesWidgetState createState() => _ObjectGesturesWidgetState();
}

class _ObjectGesturesWidgetState extends State<ObjectGesturesWidget> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;
  double sliderValue = 1.0;

  ARNode? nodes;
  ARAnchor? anchors;

  @override
  void dispose() {
    super.dispose();
    arSessionManager!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Object Transformation Gestures'),
      ),
      body: Container(
        child: Stack(children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontal,
          ),
          // Container(
          //   height: 300,
          //   width: 300,
          //   child: const ModelViewer(
          //     // backgroundColors: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
          //     src: 'assets/images/gas_tank.glb',
          //     alt: 'A 3D model of an astronaut',
          //     ar: true,
          //     arModes: ['scene-viewer', 'webxr', 'quick-look'],
          //     autoRotate: false,
          //     iosSrc: 'https://modelviewer.dev/shared-assets/models/Astronaut.usdz',
          //     disableZoom: false,
          //   ),
          // ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton(
                onPressed: onRemoveEverything,
                child: const Text("Remove Everything"),
              ),
            ]),
          ),
          // Positioned(
          //   bottom: 100,
          //   left: 10,
          //   right: 10,
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     mainAxisSize: MainAxisSize.max,
          //     children: <Widget>[
          //       Slider(
          //         value: sliderValue,
          //         onChanged: (v) {
          //           setState(() {
          //             sliderValue = v;
          //           });
          //         },
          //       ),
          //     ],
          //   ),
          // ),
        ]),
      ),
    );
  }

  void onARViewCreated(ARSessionManager arSessionManager, ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager, ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager!.onInitialize(
          showFeaturePoints: true,
          showPlanes: true,
          customPlaneTexturePath: "Images/triangle.png",
          showWorldOrigin: true,
          handlePans: true,
          handleRotation: true,
        );
    this.arObjectManager!.onInitialize();

    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arObjectManager!.onPanStart = onPanStarted;
    this.arObjectManager!.onPanChange = onPanChanged;
    this.arObjectManager!.onPanEnd = onPanEnded;
    this.arObjectManager!.onRotationStart = onRotationStarted;
    this.arObjectManager!.onRotationChange = onRotationChanged;
    this.arObjectManager!.onRotationEnd = onRotationEnded;
  }

  Future<void> onRemoveEverything() async {
    /*nodes.forEach((node) {
      this.arObjectManager.removeNode(node);
    });*/
    if (anchors != null) {
      arAnchorManager!.removeAnchor(anchors!);
    }
    anchors = null;
  }

  Future<void> onLocalObjectAtOriginButtonPressed(List<ARHitTestResult> hitTestResults) async {
    if (nodes != null) {
      arObjectManager!.removeNode(nodes!);
      nodes = null;
    } else {
      var singleHitTestResult = hitTestResults
          .firstWhere((hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
      var newAnchor = ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
      anchors = newAnchor;
      bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
      var newNode = ARNode(
          type: NodeType.webGLB,
          uri:
              "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/Tanks.glb?raw=true",
          // type: NodeType.localGLTF2,
          // uri: "assets/tanks.gltf",
          scale: Vector3(sliderValue, sliderValue, sliderValue),
          position: Vector3(0.0, 0.0, 0.0),
          rotation: Vector4(1.0, 0.0, 0.0, 0.0));
      bool? didAddLocalNode = await arObjectManager!.addNode(newNode);
      nodes = (didAddLocalNode!) ? newNode : null;
      bool? didAddNodeToAnchor = await arObjectManager!.addNode(newNode, planeAnchor: newAnchor);
    }
  }

  Future<void> onPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) async {
    var singleHitTestResult = hitTestResults
        .firstWhere((hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    if (singleHitTestResult != null) {
      var newAnchor = ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
      bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
      if (didAddAnchor!) {
        // anchors.add(newAnchor);
        // Add note to anchor
        var newNode = ARNode(
            type: NodeType.webGLB,
            uri:
                "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/Tanks.glb?raw=true",
            // type: NodeType.localGLTF2,
            // uri: "assets/tanks.gltf",
            scale: Vector3(sliderValue, sliderValue, sliderValue),
            position: Vector3(0.0, 0.0, 0.0),
            rotation: Vector4(1.0, 0.0, 0.0, 0.0));
        bool? didAddNodeToAnchor = await arObjectManager!.addNode(newNode, planeAnchor: newAnchor);
        if (didAddNodeToAnchor!) {
          // nodes.add(newNode);
        } else {
          arSessionManager!.onError("Adding Node to Anchor failed");
        }
      } else {
        arSessionManager!.onError("Adding Anchor failed");
      }
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
