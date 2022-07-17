import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'camera.dart';
import 'constants.dart' as constants;
import 'package:camera/camera.dart';
import 'database.dart';

late List<CameraDescription> _cameras;

class SelectionMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text(constants.selectionMenuTitle)),
        body: // add a list of two options
            ListView(children: <Widget>[
          ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text(constants.selectCameraTitle),
              subtitle: const Text(constants.selectCameraDescription),
              onTap: // prepare the cameras for taking a photo
                  () async {
                WidgetsFlutterBinding.ensureInitialized();
                try {
                  _cameras = await availableCameras();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CameraPage(cameras: _cameras)));
                } on MissingPluginException catch (e) {
                  print(e);
                  // if the plugin doesn't work for the platform, display a message
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AlertDialog(
                                  title: Text(constants.pluginMissingTitle),
                                  content:
                                      Text(constants.pluginMissingDescription),
                                  actions: <Widget>[
                                    TextButton(
                                        child: Text(constants.dialogOk),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        })
                                  ])));
                }
              }),
          // const ListTile(
          //   leading: Icon(Icons.table_rows_outlined),
          //   title: Text(constants.selectDatabaseTitle),
          //   subtitle: Text(constants.selectDatabaseDescription),
          // ),
          // ListTile(
          //     leading: Icon(Icons.new_label_outlined),
          //     title: Text(constants.selectNewRecordTitle),
          //     subtitle: Text(constants.selectNewRecordDescription),
          //     onTap: () {
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //               builder: (context) => NewCustomProduct()));
          //     })
        ]));
  }
}
