// Homepage
// Widgets:
// - side bar for accessing different pages
// - a short guide
// - a button to get started
// Layout:
/*

Sidebar
v
------------------
|= Recycle Helper|
| Welcome!       |
| ...            |
|           (+)  |
------------------
             ^
     Action button

*/

import 'package:flutter/material.dart';
import 'selection_menu.dart';
import 'constants.dart' as constants;

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // welcome text
        body: SafeArea(
            child: Align(
                alignment: const Alignment(0.0, -1.0), // top center
                child:
                    // also add some padding
                    Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text.rich(TextSpan(children: [
                          TextSpan(
                              text: '${constants.welcomeText}\n',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .headline2
                                      ?.fontSize)),
                          const TextSpan(text: constants.welcomeText2)
                        ]))))),
        // action button on the bottom right
        floatingActionButton: FloatingActionButton(
            // transfer to the selection menu (i.e. add manually or camera?)
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => SelectionMenu())),
            child: const Icon(Icons.add, color: Colors.white)));
  }
}
