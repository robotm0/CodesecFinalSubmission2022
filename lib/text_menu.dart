// custom widget for the About page, copyright and environment tips

import 'package:flutter/material.dart';

class TextPage extends StatelessWidget {
  String title;
  String description;
  TextPage({Key? key, required this.title, required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Align(
              alignment: const Alignment(0.0, -1.0), // top center
              child:
                  // also add some padding
                  Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text.rich(TextSpan(children: [
                            TextSpan(
                                text: '$title\n',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .headline4
                                        ?.fontSize)),
                            TextSpan(text: description)
                          ])))))),
    );
  }
}
