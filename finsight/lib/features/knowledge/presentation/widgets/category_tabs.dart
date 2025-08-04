import 'package:flutter/material.dart';

class CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          final categoryColor = _getCategoryColor(category);

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onCategorySelected(category),
                borderRadius: BorderRadius.circular(25),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? categoryColor
                        : categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: categoryColor.withValues(
                        alpha: isSelected ? 1.0 : 0.3,
                      ),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: categoryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: 16,
                        color: isSelected ? Colors.white : categoryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected ? Colors.white : categoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Colors.grey[700]!;
      case 'budgeting':
        return Colors.blue;
      case 'investing':
        return Colors.green;
      case 'savings':
        return Colors.orange;
      case 'credit':
        return Colors.purple;
      case 'tax':
        return Colors.red;
      case 'income':
        return Colors.teal;
      case 'retirement':
        return Colors.indigo;
      case 'insurance':
        return Colors.cyan;
      case 'real estate':
        return Colors.brown;
      case 'cryptocurrency':
        return Colors.amber;
      case 'banking':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.dashboard;
      case 'budgeting':
        return Icons.account_balance_wallet;
      case 'investing':
        return Icons.trending_up;
      case 'savings':
        return Icons.savings;
      case 'credit':
        return Icons.credit_card;
      case 'tax':
        return Icons.receipt;
      case 'income':
        return Icons.attach_money;
      case 'retirement':
        return Icons.elderly;
      case 'insurance':
        return Icons.security;
      case 'real estate':
        return Icons.home;
      case 'cryptocurrency':
        return Icons.currency_bitcoin;
      case 'banking':
        return Icons.account_balance;
      default:
        return Icons.category;
    }
  }
}
