// Data on rating products
// Includes search targets that are useful for flagging for rating
// e.g. positive targets include recyclable packaging ("PET-1" or "Carton")
// negative targets include imported products

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class SearchTarget {
  // positive = environmentally friendly
  num points = 0;
  String description = "";
  Function(Product) targetMet;
  SearchTarget(
      {Key? key,
      required this.targetMet,
      required this.points,
      required this.description});
}

var positiveTargets = [
  // few ingredients - a sign of unprocessed food
  SearchTarget(
    points: 1,
    targetMet: (Product p) {
      if (p.ingredients == null) {
        return false;
      } else {
        return p.ingredients!.length < 6;
      }
    },
    description:
        "Fewer ingredients - a sign of unprocessed food which helps the environment!",
  ),
  // recyclable packaging
  SearchTarget(
      points: 1,
      targetMet: (Product p) {
        var isRecyclable = true;
        for (var i in nonRecyclableMaterials) {
          for (var p in p.packagingTags ?? []) {
            if (p.contains(i)) {
              isRecyclable = false;
            }
          }
        }
        return isRecyclable;
      },
      description:
          "All recyclable! (Maybe. Check the packaging - there is likely incomplete data)"),
  // locally made
  SearchTarget(
      points: 1,
      targetMet: (Product p) {
        return ((p.countries ?? "").contains("United Kingdom"));
      },
      description: "Locally manufactured in the UK."),
];

var negativeTargets = [
// many ingredients - a sign of processed food
  SearchTarget(
    points: -1,
    targetMet: (Product p) {
      if (p.ingredients == null) {
        return false;
      } else {
        return p.ingredients!.length > 15;
      }
    },
    description:
        "Many ingredients - a sign of processed food which is bad for the environment",
  ),
  // difficult-to-recycle packaging
  SearchTarget(
      points: -1,
      targetMet: (Product p) {
        var isNotRecyclable = false;
        for (var i in nonRecyclableMaterials + partlyRecyclableMaterials) {
          for (var p in p.packagingTags ?? []) {
            if (p.contains(i)) {
              isNotRecyclable = true;
            }
          }
        }
        return isNotRecyclable;
      },
      description:
          "Check the packaging - some of the ingedients might be difficult or not possible to recycle."),
];

// which materials are recyclable in the UK
// note: when localising this should adapt for the country's recycling system
const fullyRecyclableMaterials = [
  // materials you can recycle in the bin
  "steel",
  "aluminium",
  "card",
  "glass",
  "paper",
  "pete",
  "hdpe",
  "polypropylene",
];

const partlyRecyclableMaterials = [
  // materials you can recycle at the recycling centre
  // (varies depending on location)
  "pvc",
  "ldpe",
  "polystyrene",
];

const nonRecyclableMaterials = [
  "mixed-plastic",
];

// CO2 emissions from ingredients, kg CO2 per kg food
const ingredientEmissions = {
  'beef': 35,
  'lamb': 24,
  'mutton': 24,
  'cheese': 21,
  'chocolate': 19,
  'coffee': 17,
  'prawns': 12,
  'palm oil': 8,
  'pork': 7,
  'poultry': 6,
  'chicken': 6,
  'turkey': 6,
  'olive oil': 6,
  'fish': 4,
  'eggs': 4.5,
  'rice': 4,
  'milk': 3,
  'sugar': 3,
  'nuts': 2.5,
  'wheat': 1.4,
  'tomato': 1.4,
  'corn': 1.0,
  'cassava': 1.0,
  'soy': 0.9,
  'peas': 0.9,
  'banana': 0.7,
  'carrot': 0.4,
  'potato': 0.4,
  'beet': 0.4,
  'parsnip': 0.4,
  'yam': 0.4,
  'apple': 0.4,
  'orange': 0.4,
  'lemon': 0.4,
  'lime': 0.4,
};

const List<String> positive_labels = [
  "No palm oil",
  "Palm oil free",
  "Organic",
  "Free range",
  "Green Dot",
  "Rainforest Alliance"
];

// no negative labels for now
const List<String> negative_labels = [];
