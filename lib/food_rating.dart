import 'dart:math';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'database.dart' as database;
import 'food_rating_data.dart' as rating_data;
import 'constants.dart' as constants;

// Food rating widget structure:
/*
-----------
| Title   |
| oooo.   | < Score out of 5
| 0.1kg   | < CO2 estimate per serving (or total if unavailable)
| +1 ...  |
| +1 ...  | < Awards
| -1 ...  |
| Glass Y |
| HDPE  - |
| Mixed N | < Recycling 
| Plastic |
|         |
| o     o | < save and close
-----------
  ^
close without saving

*/

double getIngredientCarbon(Ingredient i) {
  // lookup in database
  double total = 0.0;
  for (var j in rating_data.ingredientEmissions.keys) {
    if (i.text!.contains(j)) {
      var emissionPerKg = rating_data.ingredientEmissions[j] ?? 0.0;
      // it is a weighted average, so multiply by the percentage
      // let's suppose around 10 ingredients per product
      // proportion assumed to follow inverse distribution
      // P(X=x) = k/x
      // sum of x from 1 to 10 is k*2.93 == 1 by assumption
      // k ~= 0.33
      // if all else fails assume 5 percent
      var percentage = i.percent ?? i.percentEstimate ?? 33 / (i.rank ?? 10);
      var weightedEmission = emissionPerKg * percentage / 100;
      total += weightedEmission;
      break;
    }
  }
  return total;
}

double estimateCarbon(List<Ingredient> l) {
  // gives the carbon dioxide per kilogram
  double total = 0.0;
  for (Ingredient i in l) {
    // get CO2 data
    total += getIngredientCarbon(i);
    // some recipes have ingredients within ingredients
    // e.g. Ketchup (Tomato sauce, Vinegar, ...)
    // apply recursion
    total += estimateCarbon(i.ingredients ?? []);
  }
  return total;
}

List<String> checkLabels(List<String> l, Product p) {
  // returns the labels which have matched in the product
  List<String> outputList = [];
  for (String i in l) {
    if ((p.labelsTags ?? []).contains(i)) {
      outputList.add(i);
    }
  }
  return outputList;
}

bool searchList(List<String> l, String searchString) {
  // go through elements of the list, if any of them are in the searchString
  // then return true
  for (String e in l) {
    if (searchString.contains(e)) {
      return true;
    }
  }
  return false;
}

double getStars(Product p) {
  // how the reward algorithm works:
  // start off with 2.5 stars
  // for each positive award add half a star
  // opposite for negative awards
  // also add stars based on CO2 emissions with arbitrarily chosen linear regression
  // if it's lower than 10 that is 'good'
  // so numStars += 2-0.2(CO2)
  double numStars = 2.5;
  numStars += 0.5 * checkLabels(rating_data.positive_labels, p).length;
  numStars -= 0.5 * checkLabels(rating_data.negative_labels, p).length;

  for (var t in rating_data.positiveTargets + rating_data.negativeTargets) {
    if (t.targetMet(p)) {
      // for negative targets, points is negative
      numStars += t.points;
    }
  }
  var carbonEstimate = estimateCarbon(p.ingredients ?? []);
  print("Carbon estimated: $carbonEstimate");
  numStars += 1 - 0.2 * carbonEstimate;
  // constrain numStars between 0 and 5
  numStars = max(min(5, numStars), 0);
  return numStars;
}

class FoodRatingWidget extends StatelessWidget {
  Product product;
  FoodRatingWidget({Key? key, required this.product}) : super(key: key);

  List<ListTile> generateList(Product p) {
    var goodLabels = checkLabels(rating_data.positive_labels, p);
    var badLabels = checkLabels(rating_data.negative_labels, p);
    // round estimated carbon emissions to 2 d.p.
    var carbon =
        num.parse(estimateCarbon(p.ingredients ?? []).toStringAsFixed(2));
    // generates the list of ListTiles which will be displayed
    // first add the title
    var children = [
      ListTile(
        title: Text(p.productName ?? ""),
        subtitle: Text(p.barcode ?? ""),
      ),
      // 5-star rating
      ListTile(
          title: RatingBarIndicator(
        rating: getStars(p),
        itemBuilder: (context, index) => Icon(Icons.star, color: Colors.green),
      )),
      // CO2 estimate
      ListTile(
        leading: Icon(Icons.grass),
        iconColor: Colors.green,
        title: Text("CO2: ${carbon} kg/kg food"),
      ),
    ];
    if (goodLabels.isNotEmpty) {
      children.add(ListTile(
        leading: Icon(Icons.check_box),
        title: Text(constants.positiveLabelTitle),
        subtitle: Text(goodLabels.join(", ")),
        iconColor: Colors.green,
      ));
    }
    if (badLabels.isNotEmpty) {
      children.add(ListTile(
        leading: Icon(Icons.indeterminate_check_box),
        title: Text(constants.negativeLabelTitle),
        subtitle: Text(badLabels.join(", ")),
        iconColor: Colors.red,
      ));
    }
    // add the target data, if there is any
    for (rating_data.SearchTarget t
        in rating_data.positiveTargets + rating_data.negativeTargets) {
      if (t.targetMet(p)) {
        // include the target since it is met
        children.add(ListTile(
          // is the target positive? change the icon accordingly
          leading: Icon(
              t.points > 0 ? Icons.check_box : Icons.indeterminate_check_box),
          subtitle: Text(t.description),
          title: Text(t.points > 0
              ? constants.positiveTargetTitle
              : constants.negativeTargetTitle),
          iconColor: t.points > 0 ? Colors.green : Colors.red,
        ));
      }
    }
    // now to add the recycling information
    for (String m in p.packagingTags ?? []) {
      // check if recyclable at home, at center, unrecyclable or unknow
      if (searchList(rating_data.fullyRecyclableMaterials, m)) {
        // item is recyclable
        children.add(ListTile(
          leading: Icon(Icons.recycling),
          title: Text("$m can be recycled at home."),
          tileColor: Colors.green,
        ));
      } else if (searchList(rating_data.partlyRecyclableMaterials, m)) {
        // item is recyclable
        children.add(ListTile(
          leading: Icon(Icons.factory),
          title: Text("$m can only be recycled at recycling centres."),
          tileColor: Colors.amber,
        ));
      } else if (searchList(rating_data.nonRecyclableMaterials, m)) {
        // item is not recyclable
        children.add(ListTile(
          leading: Icon(Icons.delete),
          title: Text("$m cannot be recycled."),
          tileColor: Colors.red,
        ));
      } else {
        // status unknown
        children.add(ListTile(
          leading: Icon(Icons.question_mark),
          title: Text("$m Unknown - check the label to see."),
          tileColor: Colors.grey,
        ));
      }
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(constants.foodRatingTitle)),
      body: ListView(
        children: generateList(product),
      ),
      persistentFooterButtons: [
        // buttons to save/exit
        // exit with saving
        TextButton(
            onPressed: () {
              // return the user to the home screen
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(constants.exitWithoutSavingTitle)),
        TextButton(
            onPressed: () {
              // save the user's result to the database
              database.saveProduct(product);
              // return the user to the home screen
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(constants.exitWithSavingTitle))
      ],
    );
  }
}
