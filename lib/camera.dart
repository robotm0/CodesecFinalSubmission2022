// Camera widget
// To understand the initialisation process I used the docs and this tutorial from Medium:
// https://medium.com/@fernnandoptr/how-to-use-camera-in-flutter-flutter-camera-package-44defe81d2da

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'image_preview.dart';
import 'constants.dart' as constants;

class CameraPage extends StatefulWidget {
  List<CameraDescription> cameras;
  var useRearCamera;

  // Stateful Widget for updating the screen when the camera updates

  CameraPage(
      {Key? key,
      required this.cameras,
      this.useRearCamera = constants.rearCameraDefault})
      : super(key: key);
  @override
  CameraPageState createState() =>
      CameraPageState(cameras: cameras, isRearCamera: useRearCamera);
}

class CameraPageState extends State<CameraPage> {
  List<CameraDescription> cameras;
  // choose whether to select rear camera or not
  var isRearCamera;

  // check if the user has camera access
  bool hasCameraAccess = true;

  // provides behaviour for different states of the widget
  // initialisation, main state, taken an image

  // List<CameraDescription> cameras;

  // findCameras() async {
  //   cameras = await availableCameras();
  // }
  CameraPageState(
      {Key? key, required this.cameras, required this.isRearCamera});

  late CameraController _cameraController;
  // computers and laptops etc. may only have one camera
  var numCameras = 0;

  @override
  void initState() {
    // if the rear camera hasn't already been set, set it
    isRearCamera ??= constants.rearCameraDefault;
    // initialise the camera
    print("Ensuring initialisation...");
    WidgetsFlutterBinding.ensureInitialized();

    print("Getting cameras...");
    numCameras = cameras.length;
    print("numCameras: $numCameras");
    setCameras();
    super.initState();
  }

  @override
  // remove the camera function once we're done with it
  void dispose() {
    print("Test 5");
    _cameraController.dispose();
    super.dispose();
  }

  void setCameras() async {
    if (hasCameraAccess) {
      // setup the cameraController for the specific camera
      // take images at max resolution, flip based on the camera if necessary
      print("Test 1");
      _cameraController = CameraController(
          cameras[
              // override the user's choice if there is only one camera
              isRearCamera && (numCameras > 1) ? 0 : 1],
          ResolutionPreset.max);
      // disable flash
      // _cameraController.setFlashMode(FlashMode.off);
      print("Test 2i");
      try {
        await _cameraController.initialize();
      } on CameraException catch (e) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            hasCameraAccess = false;
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
      setState(() {});
      print("Test 3");
    }
  }

  // build the actual camera preview
  @override
  Widget build(BuildContext context) {
    // display a blank screen if uninitialised
    if (!hasCameraAccess) {
      return AlertDialog(
          title: Text(constants.noCameraPermissionsTitle),
          content: Text(constants.noCameraPermissionsDescription),
          actions: <Widget>[
            TextButton(
                child: Text(constants.dialogOk),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ]);
    } else if (!_cameraController.value.isInitialized) {
      print("Test 4i");
      return Container();
    }
    // camera app structure:
    // ---------
    // | food  |
    // |       |
    // ---------
    // O   O < take picture
    // ^
    // flip camera
    // then once picture taken:
    // ----------
    // | ------ |
    // | |food| | < image taken
    // | ------ |
    // |    __O | < "Looks good?" + OK button
    // ----------
    // OK button closes the camera and moves to the barcode scanner section
    else {
      print("Test 4ii");
      return Scaffold(
          appBar: AppBar(title: Text(constants.cameraMenuTitle)),
          body: Column(
            children: [
              CameraPreview(_cameraController),
              Row(
                children: [
                  // button to flip camera
                  // only include if there is more than one camera, otherwise
                  // include an empty widget (Container())
                  numCameras > 1
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                              icon: Icon(Icons.flip_camera_android),
                              onPressed: () {
                                // make a new widget with the camera flipped
                                isRearCamera = !isRearCamera;
                                setCameras();
                              }),
                        )
                      : Container(),
                  // button to take photo
                  Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.circle_outlined),
                        // take a picture
                        //onPressed: takePicture
                        onPressed: () async {
                          // try to take an image and save it
                          try {
                            // we are sure that the camera is initialised
                            // wait to take image
                            final image = await _cameraController.takePicture();
                            // display image on the new screen
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CameraPreviewPage(
                                    previewImageFile: image)));
                          } catch (e) {
                            // display error message
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AlertDialog(
                                            title: Text(e.toString()),
                                            actions: <Widget>[
                                              TextButton(
                                                  child:
                                                      Text(constants.dialogOk),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  })
                                            ])));
                          }
                        },
                      ))
                ],
              )
            ],
          ));
    }
  }
}
