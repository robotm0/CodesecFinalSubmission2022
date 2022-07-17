import 'package:flutter/material.dart';
import 'package:scan/scan.dart';

class BarcodeScan {
  static Future<String> ScanBarcode(String inputImagePath) async {
    String output = await Scan.parse(inputImagePath) ?? "";
    return output;
  }
}
