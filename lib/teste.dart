import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Set<String> selected = Set.from([]);  // Set to hold selected items

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Display selected items as a string separated by commas
          Text(
            selected.isEmpty ? 'Select items' : selected.join(' , '),
            style: TextStyle(fontSize: 16),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: DropdownButtonFormField(
              onChanged: (x) {},  // This is required but not used in this custom implementation
              items: ['a', 'b', 'c', 'd', 'e'].map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: StatefulBuilder(
                    builder: (context, _setState) {
                      return Row(
                        children: [
                          // Checkbox to select/deselect items
                          Checkbox(
                            value: selected.contains(e),
                            onChanged: (isSelected) {
                              if (isSelected == true) {
                                selected.add(e);  // Add item if selected
                              } else {
                                selected.remove(e);  // Remove item if deselected
                              }
                              _setState(() {});  // Update checkbox state
                              setState(() {});  // Update parent widget
                            },
                          ),
                          SizedBox(width: 4),  // Add space between checkbox and text
                          Text(e),  // Display item label
                        ],
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}