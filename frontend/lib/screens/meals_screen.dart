import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  bool _isVegetarian = true;
  int _selectedGoal = 1; // 0=Bulk, 1=Maintain, 2=Cut
  int _selectedMeal = 0; // 0=Breakfast, 1=Lunch, 2=Snacks, 3=Dinner

  final _goals = ['Bulk', 'Maintain', 'Cut'];
  final _goalColors = [Colors.blue, AppTheme.primaryGreen, Colors.orange];
  final _meals = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];

  Map<String, dynamic> get _nutrition {
    if (!_isVegetarian) {
      return {'calories': 2000, 'protein': 132, 'carbs': 196, 'fat': 68};
    }
    return {'calories': 2000, 'protein': 68, 'carbs': 280, 'fat': 51};
  }

  List<Map<String, dynamic>> get _breakfastOptions {
    if (_isVegetarian) {
      return [
        {'name': 'Milk + Apple', 'cal': 400, 'protein': 10, 'carbs': 15, 'fat': 12},
        {'name': 'Upma + Curd', 'cal': 500, 'protein': 18, 'carbs': 70, 'fat': 14},
      ];
    }
    return [
      {'name': 'Eggs + Toast + Fruit', 'cal': 500, 'protein': 20, 'carbs': 43, 'fat': 20},
      {'name': 'Oats + 2 Eggs', 'cal': 355, 'protein': 15, 'carbs': 10, 'fat': 15},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: AppTheme.primaryGreen,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Meal Plans', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('Personalised nutrition guidance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Diet Preference
                  const Text('Diet Preference', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _DietChip(label: 'Vegetarian', icon: Icons.eco, selected: _isVegetarian, onTap: () => setState(() => _isVegetarian = true)),
                      const SizedBox(width: 12),
                      _DietChip(label: 'Non-Vegetarian', icon: Icons.set_meal, selected: !_isVegetarian, onTap: () => setState(() => _isVegetarian = false)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Nutrition Goal
                  const Text('Nutrition Goal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(3, (i) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedGoal = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedGoal == i ? _goalColors[i] : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _selectedGoal == i ? _goalColors[i] : AppTheme.dividerColor),
                          ),
                          child: Text(
                            _goals[i],
                            style: TextStyle(
                              color: _selectedGoal == i ? Colors.white : AppTheme.textGrey,
                              fontWeight: _selectedGoal == i ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                  // Nutrition summary
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 10, height: 10, decoration: BoxDecoration(color: _goalColors[_selectedGoal], shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(
                              '${_goals[_selectedGoal].toUpperCase()} (${_selectedGoal == 1 ? "Balanced" : _goals[_selectedGoal]})',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _NutritionPill(value: '${_nutrition['calories']}', label: 'Calories', color: _goalColors[_selectedGoal]),
                            _NutritionPill(value: '${_nutrition['protein']}g', label: 'Protein', color: Colors.red.shade400),
                            _NutritionPill(value: '${_nutrition['carbs']}g', label: 'Carbs', color: Colors.orange),
                            _NutritionPill(value: '${_nutrition['fat']}g', label: 'Fat', color: Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Meal tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_meals.length, (i) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedMeal = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedMeal == i ? AppTheme.primaryGreen : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _selectedMeal == i ? AppTheme.primaryGreen : AppTheme.dividerColor),
                            ),
                            child: Text(
                              _meals[i],
                              style: TextStyle(
                                color: _selectedMeal == i ? Colors.white : AppTheme.textGrey,
                                fontSize: 13,
                                fontWeight: _selectedMeal == i ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      )),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Breakfast options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_meals[_selectedMeal]} Options',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      const Icon(Icons.restaurant_menu, size: 18, color: AppTheme.primaryGreen),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ..._breakfastOptions.map((opt) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(opt['name'] as String,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _MacroChip(value: '${opt['cal']}', label: 'Cal', color: _goalColors[_selectedGoal]),
                                  _MacroChip(value: '${opt['protein']}g', label: 'Protein', color: Colors.red.shade400),
                                  _MacroChip(value: '${opt['carbs']}g', label: 'Carbs', color: Colors.orange),
                                  _MacroChip(value: '${opt['fat']}g', label: 'Fat', color: Colors.blue),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                  // Quick Tips
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quick Tips', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        const SizedBox(height: 8),
                        _tipRow('Eat at maintenance calories to stabilize weight'),
                        _tipRow('Focus on balanced macronutrients'),
                        _tipRow('Maintain consistent meal timing'),
                      ],
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
}

class _DietChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _DietChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? AppTheme.primaryGreen : AppTheme.dividerColor, width: selected ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppTheme.primaryGreen : AppTheme.textGrey, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, color: selected ? AppTheme.primaryGreen : AppTheme.textGrey, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutritionPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _NutritionPill({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
      ],
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _MacroChip({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textGrey)),
      ],
    );
  }
}

Widget _tipRow(String tip) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
        Expanded(child: Text(tip, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey))),
      ],
    ),
  );
}