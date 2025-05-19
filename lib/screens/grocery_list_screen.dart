import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/screens/new_item_screen.dart';
import 'package:shopping_list_app/widgets/grocery_list_item.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final List<GroceryItem> _groceryItems = [];

  void _addItem() async {
    final newItems = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => NewItemScreen()));

    if (newItems != null) {
      setState(() {
        _groceryItems.add(newItems);
      });
    }
  }

  void _removeItem(GroceryItem item) {
    final expenseIndex = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item removed...'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _groceryItems.insert(expenseIndex, item);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Groceries',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
        ),
        actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
      ),
      body:
          _groceryItems.isEmpty
              ? Center(
                child: Text(
                  'You got no items yet.',
                  style: TextStyle(fontSize: 18.0),
                ),
              )
              : ListView.builder(
                itemCount: _groceryItems.length,
                itemBuilder: (context, index) {
                  final item = _groceryItems[index];

                  // return GroceryListItem(item: item);
                  return Dismissible(
                    key: ValueKey(item.id),
                    child: GroceryListItem(item: item),
                    onDismissed: (direction) {
                      _removeItem(item);
                    },
                  );
                },
              ),
    );
  }
}
