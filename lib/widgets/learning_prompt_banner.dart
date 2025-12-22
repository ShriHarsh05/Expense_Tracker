import 'package:flutter/material.dart';
import '../models/expense.dart';

/// 🎯 Non-intrusive banner that appears when Miscellaneous expenses need categorization
class LearningPromptBanner extends StatefulWidget {
  final Expense expense;
  final VoidCallback onFixPressed;
  final VoidCallback onSkipPressed;
  final VoidCallback onDismiss;
  
  const LearningPromptBanner({
    super.key,
    required this.expense,
    required this.onFixPressed,
    required this.onSkipPressed,
    required this.onDismiss,
  });

  @override
  State<LearningPromptBanner> createState() => _LearningPromptBannerState();
}

class _LearningPromptBannerState extends State<LearningPromptBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  void _handleFixPressed() async {
    // Animate out before calling the fix action
    await _animationController.reverse();
    widget.onFixPressed();
  }

  void _handleSkipPressed() async {
    // Animate out before calling the skip action
    await _animationController.reverse();
    widget.onSkipPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withValues(alpha: 0.1),
                    Colors.amber.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with icon and dismiss
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.help_outline,
                            color: Colors.orange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Help me learn!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _dismiss,
                          icon: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.grey,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Expense details
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Amount
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '₹${widget.expense.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Transaction info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.expense.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                if (widget.expense.originalSms != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.expense.originalSms!.length > 50
                                        ? '${widget.expense.originalSms!.substring(0, 50)}...'
                                        : widget.expense.originalSms!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Description
                    Text(
                      'I couldn\'t determine the category for this transaction. Help me learn so I can categorize similar expenses automatically!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action buttons
                    Row(
                      children: [
                        // Fix button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _handleFixPressed,
                            icon: const Icon(
                              Icons.edit,
                              size: 18,
                            ),
                            label: const Text(
                              'Fix & Learn',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Skip button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleSkipPressed,
                            icon: const Icon(
                              Icons.skip_next,
                              size: 18,
                            ),
                            label: const Text('Skip'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                              side: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.3),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Learning benefit
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 14,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Once learned, similar transactions will be categorized automatically',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}