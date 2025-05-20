import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/screens/new_item_screen.dart';
import 'package:shopping_list_app/widgets/grocery_list_item.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  void _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.https(
      'flutter-shopping-list-2abf4-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list.json',
    );

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      setState(() {
        _error = 'Failed to fetch data. Please try again later.';
      });
    }

    final Map<String, dynamic>? groceryItems = await jsonDecode(response.body);
    final List<GroceryItem> tempListItems = [];

    if (groceryItems != null) {
      for (final item in groceryItems.entries) {
        final itemCategory =
            categories.entries
                .firstWhere((cat) => cat.value.name == item.value['category'])
                .value;

        tempListItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: itemCategory,
          ),
        );
      }
    }

    setState(() {
      _groceryItems = tempListItems;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _loadItems();
  }

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

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);

    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
      'flutter-shopping-list-2abf4-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list/${item.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }

    if (!mounted) {
      return;
    }

    if (response.statusCode < 400) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item removed...'),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('You got no items yet.', style: TextStyle(fontSize: 18.0)),
    );

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) {
          final item = _groceryItems[index];
          return Dismissible(
            key: ValueKey(item.id),
            child: GroceryListItem(item: item),
            onDismissed: (direction) {
              _removeItem(item);
            },
          );
        },
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(
          _error!,
          style: TextStyle(color: const Color.fromARGB(255, 244, 139, 54)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Groceries',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
        ),
        actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
