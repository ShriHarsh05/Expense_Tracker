import 'package:flutter/material.dart';
import '../models/expense.dart';

/// 🎯 Dialog to prompt user for category selection when auto-categorization is uncertain
class CategoryPromptDialog extends StatefulWidget {
  final double amount;
  final DateTime date;
  final String smsBody;
  final Category suggestedCategory;
  final Function(Category, String) onCategorySelected;
  
  const CategoryPromptDialog({
    super.key,
    required this.amount,
    required this.date,
    required this.smsBody,
    required this.suggestedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategoryPromptDialog> createState() => _CategoryPromptDialogState();
}

class _CategoryPromptDialogState extends State<CategoryPromptDialog> {
  late Category _selectedCategory;
  late TextEditingController _titleController;
  
  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.suggestedCategory;
    
    // Generate default title
    final timeStr = "${widget.date.hour.toString().padLeft(2, '0')}:${widget.date.minute.toString().padLeft(2, '0')}";
    _titleController = TextEditingController(
      text: "${_selectedCategory.name}: UPI $timeStr"
    );
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
  
  void _updateTitle() {
    final timeStr = "${widget.date.hour.toString().padLeft(2, '0')}:${widget.date.minute.toString().padLeft(2, '0')}";
    _titleController.text = "${_selectedCategory.name}: UPI $timeStr";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.help_outline, color: Colors.orange),
          SizedBox(width: 8),
          Text('Categorize Expense'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Amount:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // SMS preview (truncated)
            const Text(
              'Transaction:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              widget.smsBody.length > 80 
                  ? '${widget.smsBody.substring(0, 80)}...' 
                  : widget.smsBody,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Category selection
            const Text(
              'Select Category:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Category chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Category.values.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _updateTitle();
                      });
                    }
                  },
                  selectedColor: categoryColors[category]?.withOpacity(0.3),
                  avatar: Icon(
                    categoryIcons[category],
                    size: 18,
                    color: isSelected ? categoryColors[category] : Colors.grey,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Title input
            const Text(
              'Title (optional):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter custom title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              maxLength: 50,
            ),
            
            const SizedBox(height: 8),
            
            // Learning info
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'I\'ll learn from this and auto-categorize similar transactions',
                      style: TextStyle(fontSize: 11, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onCategorySelected(_selectedCategory, _titleController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Save & Learn'),
        ),
      ],
    );
  }
}

// Category colors
final Map<Category, Color> categoryColors = {
  Category.Food: Colors.orange,
  Category.Travel: Colors.blue,
  Category.Work: Colors.purple,
  Category.Leisure: Colors.pink,
  Category.Miscellaneous: Colors.grey,
};

// Category icons
final Map<Category, IconData> categoryIcons = {
  Category.Food: Icons.restaurant,
  Category.Travel: Icons.flight,
  Category.Work: Icons.work,
  Category.Leisure: Icons.movie,
  Category.Miscellaneous: Icons.more_horiz,
};