import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  List<dynamic> _plans = [];
  bool _loading = true;
  String? _error;
  String _filterGoal = 'all';
  String _filterDiet = 'all';

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthService.getToken();
      final res = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/meals/meal-plans/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() { _plans = jsonDecode(res.body); _loading = false; });
      } else {
        setState(() { _error = 'Failed to load meal plans'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Cannot connect to server'; _loading = false; });
    }
  }

  List<dynamic> get _filtered {
    return _plans.where((p) {
      final goalMatch = _filterGoal == 'all' || p['goal'] == _filterGoal;
      final dietMatch = _filterDiet == 'all' || p['diet_type'] == _filterDiet;
      return goalMatch && dietMatch;
    }).toList();
  }

  Color _goalColor(String goal) {
    switch (goal) {
      case 'bulk':     return Colors.blue;
      case 'cut':      return Colors.orange;
      default:         return AppTheme.primaryGreen;
    }
  }

  Color _dietColor(String diet) {
    switch (diet) {
      case 'vegetarian':     return AppTheme.primaryGreen;
      case 'non_vegetarian': return Colors.red;
      case 'vegan':          return Colors.teal;
      default:               return Colors.grey;
    }
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _nice(String s) => s
      .split('_')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: _loadPlans,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.primaryGreen,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meal Plans',
                        style: TextStyle(color: Colors.white, fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    Text('Choose a nutrition plan that matches your goal',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),

            // Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Goal filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['all', 'bulk', 'cut', 'maintain']
                            .map((g) => _FilterChip(
                                  label: g == 'all' ? 'All Goals' : _cap(g),
                                  selected: _filterGoal == g,
                                  color: g == 'all'
                                      ? Colors.grey
                                      : _goalColor(g),
                                  onTap: () =>
                                      setState(() => _filterGoal = g),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Diet filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'all',
                          'vegetarian',
                          'non_vegetarian',
                          'vegan'
                        ]
                            .map((d) => _FilterChip(
                                  label: d == 'all' ? 'All Diets' : _nice(d),
                                  selected: _filterDiet == d,
                                  color: d == 'all'
                                      ? Colors.grey
                                      : _dietColor(d),
                                  onTap: () =>
                                      setState(() => _filterDiet = d),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(
                    color: AppTheme.primaryGreen)),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!,
                          style: const TextStyle(color: AppTheme.textGrey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _loadPlans,
                          child: const Text('Retry')),
                    ],
                  ),
                ),
              )
            else if (_filtered.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No meal plans available.\nCheck back soon!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textGrey),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _MealPlanCard(
                      plan: _filtered[i],
                      goalColor: _goalColor(_filtered[i]['goal'] ?? ''),
                      dietColor: _dietColor(_filtered[i]['diet_type'] ?? ''),
                      cap: _cap,
                      nice: _nice,
                    ),
                    childCount: _filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label, required this.selected,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : AppTheme.dividerColor),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? Colors.white : AppTheme.textGrey,
              fontSize: 12,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.normal,
            )),
      ),
    );
  }
}

class _MealPlanCard extends StatefulWidget {
  final dynamic plan;
  final Color goalColor;
  final Color dietColor;
  final String Function(String) cap;
  final String Function(String) nice;

  const _MealPlanCard({
    required this.plan, required this.goalColor,
    required this.dietColor, required this.cap, required this.nice,
  });

  @override
  State<_MealPlanCard> createState() => _MealPlanCardState();
}

class _MealPlanCardState extends State<_MealPlanCard> {
  bool _expanded = false;
  int? _expandedMeal;

  @override
  Widget build(BuildContext context) {
    final plan  = widget.plan;
    final meals = List<dynamic>.from(plan['meals'] ?? []);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: widget.goalColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      plan['total_calories'] > 0
                          ? '${plan['total_calories']}\ncal'
                          : '—',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: widget.goalColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan['name'] ?? '',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark)),
                      if ((plan['description'] ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(plan['description'],
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textGrey)),
                        ),
                      const SizedBox(height: 8),
                      Row(children: [
                        _Badge(widget.cap(plan['goal'] ?? ''),
                            widget.goalColor),
                        const SizedBox(width: 6),
                        _Badge(widget.nice(plan['diet_type'] ?? ''),
                            widget.dietColor),
                        const SizedBox(width: 6),
                        Text('${plan['meal_count']} meals',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textGrey)),
                      ]),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      setState(() => _expanded = !_expanded),
                  child: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),

          // Expanded meals
          if (_expanded && meals.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: meals.map((meal) {
                  final isOpen = _expandedMeal == meal['id'];
                  final foods =
                      List<dynamic>.from(meal['food_items'] ?? []);
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() =>
                            _expandedMeal = isOpen ? null : meal['id']),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.scaffoldBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.nice(meal['name'] ?? ''),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textDark),
                                    ),
                                    Text(
                                      '${foods.length} items · ${meal['total_calories']} cal',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textGrey),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isOpen
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: AppTheme.textGrey,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isOpen)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.dividerColor),
                          ),
                          child: Column(
                            children: [
                              // Header row
                              const Row(children: [
                                Expanded(flex: 3,
                                    child: Text('Food',
                                        style: TextStyle(fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textGrey))),
                                Expanded(flex: 2,
                                    child: Text('Qty',
                                        style: TextStyle(fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textGrey))),
                                Expanded(flex: 2,
                                    child: Text('Cal',
                                        style: TextStyle(fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textGrey))),
                                Expanded(flex: 3,
                                    child: Text('P/C/F',
                                        style: TextStyle(fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textGrey))),
                              ]),
                              const Divider(height: 12),
                              ...foods.map((food) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 3),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Text(
                                              food['name'] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppTheme.textDark))),
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                              food['quantity'] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppTheme.textGrey))),
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                              '${food['calories']}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppTheme.textGrey))),
                                      Expanded(
                                          flex: 3,
                                          child: Text(
                                              '${food['protein']}/${food['carbs']}/${food['fat']}g',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      AppTheme.textGrey))),
                                    ]),
                                  )),
                            ],
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600)),
    );
  }
}