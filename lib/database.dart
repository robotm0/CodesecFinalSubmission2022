import 'package:localstore/localstore.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'constants.dart' as constants;

final db = Localstore.instance;

void saveProduct(Product product) {
  final id = db.collection('products').doc().id;
  // save to the database
  var time = DateTime.now().millisecondsSinceEpoch;
  db.collection('products').doc(id).set({
    // store based on the time so that we can use it for later
    'time': time,
    'product': product.toJson()
  });
  print("Time: $time");
}

Future getDatabase() async {
  final items = await db.collection('products').get();
  return items;
}

class NewCustomProduct extends StatefulWidget {
  // this will be a form for the new product
  const NewCustomProduct({super.key});

  @override
  NewCustomProductState createState() {
    return NewCustomProductState();
  }
}

class NewCustomProductState extends State<NewCustomProduct> {
  // global key for the form to assist in identification
  final _formKey = GlobalKey<FormState>();
  final _formController = TextEditingController();

  String productName = "";
  String productIngredientsStr = "";

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  void submit() {
    _formKey.currentState!.save();
    // convert ingredients
    List<Ingredient> productIngredients = [];
    List<String> productIngredientsStrArr = productIngredientsStr.split(",");
    int i = 1;
    for (var s in productIngredientsStrArr) {
      productIngredients.add(Ingredient(text: s, rank: i));
      i++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: <Widget>[
          // the form has multiple fields
          // ingredients (with optional percentages)
          // packaging
          // the elements in the list are separated by commas
          // percentages are converted
          // e.g. "45% Oat Flakes, Sugar, 9% Crisped Rice"
          // becomes:
          // [Oat Flakes : 45%
          //  Sugar:       ??% (will need to estimate using linear interpolation)
          //  Crisped Rice: 9%]
          TextFormField(
            decoration: InputDecoration(labelText: "Product name"),
            onSaved: (String? value) {
              productName = value!;
            },
            validator: (String? value) {
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText:
                    "Ingredients (with percentages) separated by commas"),
            onSaved: (String? value) {
              productIngredientsStr = value!;
            },
            validator: (String? value) {
              return null;
            },
          ),
          TextButton(
            child: Text(constants.dialogOk),
            onPressed: this.submit,
          )
        ]));
  }
}
