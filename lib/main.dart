import 'package:flutter/material.dart';
import 'constants.dart' as constants;
import 'home_page.dart';
import 'text_menu.dart';

void main() {
  // ensure that we can initialise the camera app to avoid nasty exceptions
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // widget serves as a container for pages (homepage, settings, log etc)
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // the main page to display
  Widget mainWidget = Homepage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: constants.programTitle,
        home: Builder(
            builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text(constants.programTitle)),
                  drawer: SafeArea(
                      child: Drawer(
                          child: ListView(
                              padding: EdgeInsets.zero,
                              children: <Widget>[
                        ListTile(
                            leading: const Icon(Icons.home),
                            title: const Text(constants.homepageName),
                            onTap: () {
                              // what to do when the user taps the Homepage button
                              // we want to move to the homepage and close the sidebar
                              setState(() {
                                mainWidget = Homepage();
                              });
                              Navigator.pop(context);
                            }),
                        ListTile(
                            leading: const Icon(Icons.info),
                            title: const Text(constants.aboutPageName),
                            onTap: () {
                              setState(() {
                                mainWidget = TextPage(
                                  title: constants.aboutPageName,
                                  description: constants.aboutPageDescription,
                                );
                              });
                              Navigator.pop(context);
                            }),
                        ListTile(
                            leading: const Icon(Icons.tips_and_updates),
                            title: const Text(constants.tipsPageName),
                            onTap: () {
                              // what to do when the user taps the Homepage button
                              // we want to move to the homepage and close the sidebar
                              setState(() {
                                mainWidget = TextPage(
                                  title: constants.tipsPageName,
                                  description: constants.tipsPageDescription,
                                );
                              });
                              Navigator.pop(context);
                            }),
                      ]))),
                  body: mainWidget,
                )));
  }
}
