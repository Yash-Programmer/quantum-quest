import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/budget.dart';
import '../../providers/budget_provider.dart';
import '../../../../core/theme/app_theme.dart';

class AddBudgetDialog extends ConsumerStatefulWidget {
  final Budget? budget; // If provided, we're editing
  final Function(Budget) onBudgetCreated;

  const AddBudgetDialog({super.key, this.budget, required this.onBudgetCreated});

  @override
  ConsumerState<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends ConsumerState<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _budgetAmountController = TextEditingController();
  final _alertThresholdController = TextEditingController();

  BudgetCategory? _selectedCategory;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  bool _alertsEnabled = true;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();

    if (widget.budget != null) {
      // Editing mode
      final budget = widget.budget!;
      _budgetAmountController.text = budget.budgetAmount.toStringAsFixed(0);
      _alertThresholdController.text = budget.alertThreshold.toStringAsFixed(0);
      _selectedPeriod = budget.period;
      _alertsEnabled = budget.alertsEnabled;
      _customStartDate = budget.startDate;
      _customEndDate = budget.endDate;

      // Find the matching category
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final categories = ref.read(budgetCategoriesProvider);
        _selectedCategory = categories.firstWhere(
          (cat) => cat.id == budget.categoryId,
          orElse: () => categories.first,
        );
        setState(() {});
      });
    } else {
      // Creating mode
      _alertThresholdController.text = '80';
    }
  }

  @override
  void dispose() {
    _budgetAmountController.dispose();
    _alertThresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(budgetCategoriesProvider);
    final isEditing = widget.budget != null;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(isEditing ? Icons.edit : Icons.add, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Edit Budget' : 'Create New Budget',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category selection
                      Text(
                        'Category',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<BudgetCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        hint: const Text('Select a category'),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(
                                  _getIconData(category.icon),
                                  size: 20,
                                  color: Color(
                                    int.parse(
                                      category.color.replaceAll('#', '0xFF'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(category.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: isEditing
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                      ),
                      const SizedBox(height: 20),

                      // Budget amount
                      Text(
                        'Budget Amount',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _budgetAmountController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_rupee),
                          hintText: 'Enter budget amount',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter budget amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Period selection
                      Text(
                        'Budget Period',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<BudgetPeriod>(
                        value: _selectedPeriod,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        items: BudgetPeriod.values.map((period) {
                          return DropdownMenuItem(
                            value: period,
                            child: Text(period.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPeriod = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Custom date range (if custom period selected)
                      if (_selectedPeriod == BudgetPeriod.custom) ...[
                        Text(
                          'Custom Date Range',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectStartDate(),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Start Date',
                                    prefixIcon: Icon(Icons.date_range),
                                  ),
                                  child: Text(
                                    _customStartDate != null
                                        ? '${_customStartDate!.day}/${_customStartDate!.month}/${_customStartDate!.year}'
                                        : 'Select start date',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectEndDate(),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'End Date',
                                    prefixIcon: Icon(Icons.date_range),
                                  ),
                                  child: Text(
                                    _customEndDate != null
                                        ? '${_customEndDate!.day}/${_customEndDate!.month}/${_customEndDate!.year}'
                                        : 'Select end date',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Alert settings
                      Row(
                        children: [
                          Switch(
                            value: _alertsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _alertsEnabled = value;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Enable Budget Alerts',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      if (_alertsEnabled) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Alert Threshold (%)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _alertThresholdController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.notifications),
                            hintText: 'e.g., 80 for 80%',
                            suffixText: '%',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (_alertsEnabled &&
                                (value == null || value.isEmpty)) {
                              return 'Please enter alert threshold';
                            }
                            if (_alertsEnabled) {
                              final threshold = double.tryParse(value!);
                              if (threshold == null ||
                                  threshold < 1 ||
                                  threshold > 100) {
                                return 'Please enter a value between 1 and 100';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveBudget,
                      child: Text(
                        isEditing ? 'Update Budget' : 'Create Budget',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _customStartDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _customStartDate = date;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _customEndDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: _customStartDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _customEndDate = date;
      });
    }
  }

  void _saveBudget() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final budgetAmount = double.parse(_budgetAmountController.text);
    final alertThreshold = _alertsEnabled
        ? double.parse(_alertThresholdController.text)
        : 80.0;

    DateTime startDate, endDate;

    if (_selectedPeriod == BudgetPeriod.custom) {
      if (_customStartDate == null || _customEndDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select custom date range')),
        );
        return;
      }
      startDate = _customStartDate!;
      endDate = _customEndDate!;
    } else {
      startDate = DateTime.now();
      endDate = startDate.add(_selectedPeriod.duration);
    }

    final budget = Budget(
      id: widget.budget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      categoryId: _selectedCategory!.id,
      categoryName: _selectedCategory!.name,
      budgetAmount: budgetAmount,
      spentAmount: widget.budget?.spentAmount ?? 0.0,
      startDate: startDate,
      endDate: endDate,
      period: _selectedPeriod,
      status: BudgetStatus.active,
      alertsEnabled: _alertsEnabled,
      alertThreshold: alertThreshold,
      createdAt: widget.budget?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onBudgetCreated(budget);
    Navigator.of(context).pop();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'movie':
        return Icons.movie;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'school':
        return Icons.school;
      case 'bolt':
        return Icons.bolt;
      case 'subscriptions':
        return Icons.subscriptions;
      default:
        return Icons.category;
    }
  }
}
