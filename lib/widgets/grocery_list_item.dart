import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

class GroceryListItem extends StatelessWidget {
  const GroceryListItem({super.key, required this.item});

  final GroceryItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.name),
      leading: Container(width: 24, height: 24, color: item.category.color),
      trailing: Text(
        item.quantity.toString(),
        style: TextStyle(fontSize: 14.0),
      ),
    );
  }
}
