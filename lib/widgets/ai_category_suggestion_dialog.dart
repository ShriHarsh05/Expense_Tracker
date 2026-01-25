import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/smart_categorizer.dart';

/// 🤖 AI-powered category suggestion dialog for user training
class AICategorySuggestionDialog extends StatefulWidget {
  final String smsBody;
  final double amount;
  final DateTime time;
  final CategorySuggestion suggestion;
  final Function(Category, String?) onCategorySelected;

  const AICategorySuggestionDialog({
    Key? key,
    required this.smsBody,
    required this.amount,
    required this.time,
    required this.suggestion,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<AICategorySuggestionDialog> createState() => _AICategorySuggestionDialogState();
}

class _AICategorySuggestionDialogState extends State<AICategorySuggestionDialog> {
  Category? selectedCategory;
  final TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-select AI suggestion
    selectedCategory = widget.suggestion.suggestedCategory;
    // Generate suggested title
    titleController.text = _generateSuggestedTitle();
  }

  String _generateSuggestedTitle() {
    final category = widget.suggestion.suggestedCategory?.name ?? 'Expense';
    final time = widget.time;
    final timeStr = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    return "$category: ₹${widget.amount} at $timeStr";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.smart_toy, color: Colors.blue),
          SizedBox(width: 8),
          Text('🤖 AI Category Suggestion'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Transaction Details
            _buildTransactionDetails(),
            SizedBox(height: 16),
            
            // AI Suggestion
            _buildAISuggestion(),
            SizedBox(height: 16),
            
            // Alternative Options
            if (widget.suggestion.alternativeOptions?.isNotEmpty == true)
              _buildAlternativeOptions(),
            
            SizedBox(height: 16),
            
            // Category Selection
            _buildCategorySelection(),
            SizedBox(height: 16),
            
            // Title Input
            _buildTitleInput(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedCategory != null ? _onSavePressed : null,
          child: Text('Save & Learn'),
        ),
      ],
    );
  }

  Widget _buildTransactionDetails() {
    return Card(
      color: Colors.grey[50],
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📱 Transaction Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text('Amount: ₹${widget.amount}'),
            Text('Time: ${_formatDateTime(widget.time)}'),
            Text('SMS: ${widget.smsBody.length > 60 ? widget.smsBody.substring(0, 60) + '...' : widget.smsBody}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAISuggestion() {
    if (widget.suggestion.suggestedCategory == null) return SizedBox.shrink();
    
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  '🤖 AI Suggestion',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(widget.suggestion.suggestionConfidence ?? 0.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${((widget.suggestion.suggestionConfidence ?? 0.0) * 100).toInt()}%',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getCategoryColor(widget.suggestion.suggestedCategory!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.suggestion.suggestedCategory!.name,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.suggestion.suggestionReason ?? 'AI analysis suggests this category',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativeOptions() {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔄 Alternative Options',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 8),
            ...widget.suggestion.alternativeOptions!.map((option) => 
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(option.category),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${option.category.name} (${(option.confidence * 100).toInt()}%)',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📂 Select Category',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Category.values.map((category) => 
            FilterChip(
              label: Text(category.name),
              selected: selectedCategory == category,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = selected ? category : null;
                  if (selected) {
                    titleController.text = _generateTitleForCategory(category);
                  }
                });
              },
              backgroundColor: selectedCategory == category 
                  ? _getCategoryColor(category) 
                  : Colors.grey[200],
              selectedColor: _getCategoryColor(category),
              labelStyle: TextStyle(
                color: selectedCategory == category ? Colors.white : Colors.black87,
                fontWeight: selectedCategory == category ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '✏️ Expense Title (Optional)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: 'Enter a descriptive title...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.edit),
          ),
          maxLength: 50,
        ),
      ],
    );
  }

  String _generateTitleForCategory(Category category) {
    final time = widget.time;
    final timeStr = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    
    switch (category) {
      case Category.Food:
        if (time.hour >= 12 && time.hour <= 14) return "Lunch: ₹${widget.amount}";
        if (time.hour >= 19 && time.hour <= 21) return "Dinner: ₹${widget.amount}";
        if (time.hour >= 7 && time.hour <= 9) return "Breakfast: ₹${widget.amount}";
        return "Food: ₹${widget.amount} at $timeStr";
      case Category.Travel:
        if (time.hour >= 7 && time.hour <= 9) return "Morning commute: ₹${widget.amount}";
        if (time.hour >= 17 && time.hour <= 19) return "Evening commute: ₹${widget.amount}";
        return "Travel: ₹${widget.amount} at $timeStr";
      case Category.Work:
        return "Work expense: ₹${widget.amount} at $timeStr";
      case Category.Leisure:
        if (time.weekday >= 6) return "Weekend activity: ₹${widget.amount}";
        return "Leisure: ₹${widget.amount} at $timeStr";
      case Category.Miscellaneous:
        return "Miscellaneous: ₹${widget.amount} at $timeStr";
    }
  }

  Color _getCategoryColor(Category category) {
    switch (category) {
      case Category.Food:
        return Colors.orange;
      case Category.Travel:
        return Colors.blue;
      case Category.Work:
        return Colors.purple;
      case Category.Leisure:
        return Colors.green;
      case Category.Miscellaneous:
        return Colors.grey;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.7) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[dateTime.weekday - 1];
    final time = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    return "$weekday, ${dateTime.day}/${dateTime.month} at $time";
  }

  void _onSavePressed() {
    widget.onCategorySelected(
      selectedCategory!,
      titleController.text.trim().isEmpty ? null : titleController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}