import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
import 'package:flutter_ar/download_helper.dart';
import 'package:flutter_ar/log.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool isLocal;

  ArObjectModel({
    required this.name,
    required this.path,
    required this.url,
    required this.androidUrl,
    this.isLocal = false,
  });

  factory ArObjectModel.fromJson(Map<String, dynamic> json) {
    return ArObjectModel(
      name: json['name'],
      path: json['path'],
      url: json['url'],
      androidUrl: json['android_url'],
      isLocal: json['is_local'] ?? false, // Use "?? false" to set default value
    );
  }
// to convert json to map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'url': url,
      'android_url': androidUrl,
      'is_local': isLocal,
    };
  }

  ArObjectModel copyWith({
    String? name,
    String? path,
    String? url,
    String? androidUrl,
    bool? isLocal,
  }) {
    return ArObjectModel(
      name: name ?? this.name,
      path: path ?? this.path,
      url: url ?? this.url,
      androidUrl: androidUrl ?? this.androidUrl,
      isLocal: isLocal ?? this.isLocal,
    );
  }
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
      path: "assets/images/tank_450.png",
      url:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/Tank_450L.glb?raw=true§",
      androidUrl:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/android_tank_450L.glb?raw=true§",
    ),
    ArObjectModel(
      name: "1000L",
      path: "assets/images/tank_4000.png",
      url:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/tank_1000L.glb?raw=true",
      androidUrl:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/android_tank_1000L.glb?raw=true",
    ),
    ArObjectModel(
      name: "2000L",
      path: "assets/images/tank_1000.png",
      url:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/tank_2000L.glb?raw=true",
      androidUrl:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/android_tank_2000L.glb?raw=true",
    ),
    ArObjectModel(
      name: "4000L",
      path: "assets/images/tank_1000.png",
      url:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/tank_4000L.glb?raw=true",
      androidUrl:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/android_tank_4000L.glb?raw=true",
    ),
    ArObjectModel(
      name: "7000L",
      path: "assets/images/tank_7000.png",
      url:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/tank_7000L.glb?raw=true",
      androidUrl:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/android_tank_7000L.glb?raw=true",
    ),
    ArObjectModel(
      name: "1000L VUG",
      path: "assets/images/tank_1000L_VUG.png",
      url:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/tank_1000L_VUG.glb?raw=true",
      androidUrl:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/android_tank_1000L_VUG.glb?raw=true",
    ),
    ArObjectModel(
      name: "1750L HUG",
      path: "assets/images/tank_1750L_HUG.png",
      url:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/tank_1750L_HUG.glb?raw=true",
      androidUrl:
          "https://github.com/abdelrahman-abied/flutter_ar/blob/main/assets/android_tank_1750L_HUG.glb?raw=true",
    ),
  ];
  initState() {
    getLocalFilePath();
    super.initState();
  }

  late final newScale;
  int selectedImage = 1;
  double _counter = 0;
  double _previousScale = 1.0;
  double _scaleFactor = 1.0;
  NodeType currentNodeType = NodeType.webGLB;
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );
    return Scaffold(
        appBar: AppBar(
          title: const Text('Screenshots'),
        ),
        body: Container(
            child: Stack(children: [
          // GestureDetector(
          // onScaleStart: (ScaleStartDetails details) {
          //   _previousScale = _scaleFactor;
          // },
          // onScaleUpdate: (ScaleUpdateDetails details) {
          //   if (details.scale != 1.0) {
          //     if (details.scale > _previousScale && _counter < 100) {
          //       _counter += 1; // Increase counter by 10%
          //       nodes.last.transform = Matrix4.identity()
          //         ..scale(nodes.last.scale * (_counter / 100));
          //     } else if (details.scale < _previousScale && _counter > 0) {
          //       _counter -= 1; // Decrease counter by 10%
          //       nodes.last.transform = Matrix4.identity()
          //         ..scale(nodes.last.scale * (_counter / 100));
          //     }
          //     _previousScale = details.scale;
          //     setState(() {});
          //   }
          // },
          // child:
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontal,
            // showPlatformType: true,
          ),
          FutureBuilder<bool>(
            future: isFileExists(arObjects[selectedImage].url),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Text(
                  "${snapshot.data}",
                  style: const TextStyle(fontSize: 40, color: Colors.blue),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          // ),
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
                              onTap: () async {
                                await onRemoveEverything();
                                debugPrint("path: 1 ${e.toJson()}}");
                                // if (!e.isLocal) {
                                //   final path = await showFutureProgressDialog<String?>(
                                //       context: context,
                                //       initFuture: () async => await downloadArModel(
                                //           Platform.isAndroid ? e.androidUrl : e.url));

                                //   if (path != null) {
                                //     e.isLocal = true;
                                //     e = ArObjectModel(
                                //       name: e.name,
                                //       path: e.path,
                                //       url: path,
                                //       androidUrl: path,
                                //       isLocal: true,
                                //     );
                                //     debugPrint("path:------    $path");
                                //     debugPrint("path: ==========   ${e.toJson()}}");
                                //     saveArObjects(e);
                                //   }
                                // }

                                // selectedImage =
                                //     arObjects.indexWhere((element) => element.name == e.name);
                                arObjects[selectedImage] = e;
                                debugPrint("path: 2 ${e.toJson()}}");
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
                Text(
                  "${arObjects[selectedImage].name}\n ${arObjects[selectedImage].url.split('/').last} \n ${arObjects[selectedImage].isLocal} \n ${arObjects[selectedImage].isLocal == false ? NodeType.webGLB : NodeType.fileSystemAppFolderGLB}",
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                            // increase scale to 10% of the current scale
                            // nodes.last.transform = Matrix4.identity()
                            //   ..scale(nodes.last.scale * 1.1);

                            nodes.first.transform = Matrix4.identity()
                              ..scale(nodes.last.scale * 1.1);
                            Log.w("data: Scale ${nodes.last.scale}");
                            Log.w("data: Rotation ${nodes.last.rotation}");
                          },
                          icon: const Icon(Icons.zoom_out_map)),
                    ),
                    Expanded(
                      child: IconButton(
                          color: Colors.white,
                          onPressed: () {
                            // decrease scale to 10% of the current scale

                            nodes.first.transform = Matrix4.identity()
                              ..scale(nodes.last.scale * .9);
                            Log.w("data: Scale ${nodes.last.scale}");
                            Log.w("data: Rotation ${nodes.last.rotation}");
                          },
                          icon: const Icon(Icons.zoom_in_map)),
                    ),
                    IconButton(
                      onPressed: () {
                        // rotateY 90  degree
                        rotate();
                        nodes.first.transform = Matrix4.identity()
                          ..scale(nodes.last.scale)
                          ..rotateY(rotationAngle);
                        Log.w("data: Scale ${nodes.last.scale}");
                        Log.w("data: Rotation ${nodes.last.rotation}");
                      },
                      icon: const Icon(
                        Icons.rotate_90_degrees_cw,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ])));
  }

  double rotationAngle = 0.0;

  void rotate() {
    setState(() {
      rotationAngle += pi / 2; // Rotate by 90 degrees
      // if (rotationAngle >= 2 * pi) {
      //   rotationAngle = 0.0; // Reset to 0 degrees after full rotation
      // }
    });
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
            type: arObjects[selectedImage].isLocal == false
                ? NodeType.webGLB
                : NodeType.fileSystemAppFolderGLB,
            // Download urls
            // uri: Platform.isIOS
            //     ? '${arObjects[selectedImage].url.split('/').last}${'?raw=true'}'
            //     : '${arObjects[selectedImage].url}${'?raw=true'}',
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

  void getLocalFilePath() async {
    final prefs = await SharedPreferences.getInstance();
    for (var arObject in arObjects) {
      final arObjectJson = prefs.getString(arObject.name);
      if (arObjectJson != null) {
        final arObjectModel = ArObjectModel.fromJson(jsonDecode(arObjectJson));
        final index = arObjects.indexWhere((element) => element.name == arObjectModel.name);
        if (index != -1) {
          arObjects[index] = arObjectModel;
        }
        debugPrint("getLocalFilePath arObjectJson: $arObjectJson");
        debugPrint("===========================================");
      }
    }
  }

  Future<String?> downloadArModel(String currentARObjectURL) async {
    try {
      var path = await DownloadHelper.downloadFile(currentARObjectURL);
      return path;
    } catch (e) {
      debugPrint("Error: $e");
      return null;
    }
  }

  // create method to save ar objects to shared preferences
  void saveArObjects(ArObjectModel arObject) async {
    arObject = arObject.copyWith(isLocal: true);
    var arObjectsJson = jsonEncode(arObject.toJson());
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(arObject.name, arObjectsJson);
  }

  Future<bool> isFileExists(String url) async {
    File file = File(url);

    bool fileExists = await file.exists();

    if (fileExists) {
      return true;
    } else {
      return false;
    }
  }
}
