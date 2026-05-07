import 'package:flutter/material.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint, // Store codePoint instead of IconData
      'color': color.value, // Store color as int
    };
  }

  // Create from map
  factory ExpenseCategory.fromMap(Map<dynamic, dynamic> map) {
    return ExpenseCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(map['color'] as int),
    );
  }
}
