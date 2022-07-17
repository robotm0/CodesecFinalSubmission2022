import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:recycle_helper/food_rating.dart';
import 'api_search.dart';
import 'constants.dart' as constants;
import 'package:cross_file_image/cross_file_image.dart';
import 'barcode_scan.dart';

class CameraPreviewPage extends StatelessWidget {
  final XFile previewImageFile;
  const CameraPreviewPage({Key? key, required this.previewImageFile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Image previewImage = Image(image: XFileImage(previewImageFile));
    return Scaffold(
        appBar: AppBar(title: Text(constants.imagePreviewTitle)),
        body: Column(
          children: [
            previewImage,
            Row(children: [
              // button to retake photo
              TextButton(
                  onPressed: () {
                    // move to the previous menu
                    Navigator.of(context).pop();
                  },
                  child: Text(constants.retakeImage)),
              // button to proceed with photo
              TextButton(
                onPressed: () async {
                  // scan the barcode
                  String barcodeResult =
                      (await BarcodeScan.ScanBarcode(previewImageFile.path));
                  // if the barcode is empty, return to the previous menu and try again
                  if (barcodeResult.isEmpty) {
                    // alert the user that the barcode is empty
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AlertDialog(
                                    title: Text(constants.barcodeEmptyTitle),
                                    content:
                                        Text(constants.barcodeEmptyDescription),
                                    actions: <Widget>[
                                      TextButton(
                                          child: Text(constants.dialogOk),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          })
                                    ])));
                  } else {
                    // pass to the search window
                    var productResult =
                        await APISearch.searchBarcode(barcodeResult);
                    if (productResult == null) {
                      // no search found
                      // display error message
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AlertDialog(
                                      title:
                                          Text(constants.missingProductTitle),
                                      content: Text(
                                          constants.missingProductDescription),
                                      actions: <Widget>[
                                        TextButton(
                                            child: Text(constants.dialogOk),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            })
                                      ])));
                    } else {
                      print("Product found");
                      // display results
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  FoodRatingWidget(product: productResult)));
                    }
                  }
                },
                child: Text(constants.proceedImage),
              )
            ])
          ],
        ));
  }
}
