import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/entities/todo_query_entity.dart';
import '../providers/todo_notifier.dart';
import '../widgets/add_todo_button.dart';

class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({super.key});

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends ConsumerState<TodoPage>
    with SingleTickerProviderStateMixin {
  static const List<_CategoryIconOption> _iconOptions = [
    _CategoryIconOption('work', Icons.work_outline_rounded),
    _CategoryIconOption('home', Icons.home_outlined),
    _CategoryIconOption('shopping', Icons.shopping_bag_outlined),
    _CategoryIconOption('health', Icons.favorite_outline_rounded),
    _CategoryIconOption('study', Icons.menu_book_rounded),
    _CategoryIconOption('travel', Icons.flight_takeoff_rounded),
    _CategoryIconOption('code', Icons.code_rounded),
    _CategoryIconOption('fitness', Icons.fitness_center_rounded),
    _CategoryIconOption('finance', Icons.account_balance_wallet_outlined),
    _CategoryIconOption('calendar', Icons.event_note_rounded),
    _CategoryIconOption('music', Icons.music_note_rounded),
    _CategoryIconOption('camera', Icons.camera_alt_outlined),
    _CategoryIconOption('pet', Icons.pets_rounded),
    _CategoryIconOption('car', Icons.directions_car_outlined),
    _CategoryIconOption('food', Icons.restaurant_menu_rounded),
    _CategoryIconOption('idea', Icons.lightbulb_outline_rounded),
    _CategoryIconOption('chat', Icons.chat_bubble_outline_rounded),
    _CategoryIconOption('gaming', Icons.sports_esports_rounded),
    _CategoryIconOption('documents', Icons.description_outlined),
    _CategoryIconOption('star', Icons.star_outline_rounded),
  ];

  static final List<Color> _presetColors = [
    const Color(0xFF3B82F6),
    const Color(0xFF6366F1),
    const Color(0xFF0EA5E9),
    const Color(0xFF06B6D4),
    const Color(0xFF10B981),
    const Color(0xFF22C55E),
    const Color(0xFFA3E635),
    const Color(0xFFFACC15),
    const Color(0xFFF59E0B),
    const Color(0xFFFB7185),
    const Color(0xFFF43F5E),
    const Color(0xFFEF4444),
    const Color(0xFFEC4899),
    const Color(0xFFA855F7),
    const Color(0xFF8B5CF6),
    const Color(0xFF64748B),
    const Color(0xFF334155),
    const Color(0xFF0EA5A4),
    const Color(0xFF84CC16),
    const Color(0xFFFF7A59),
  ];

  final _keywordCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _avatarCtrl = TextEditingController();

  bool? _isCompleted;
  int? _priority;
  String? _categoryId;
  DateTime? _dueFrom;
  DateTime? _dueTo;
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';
  int _page = 1;
  final int _pageSize = 10;
  late final TabController _tabController;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this)
      ..addListener(() {
        if (_activeTab != _tabController.index) {
          setState(() => _activeTab = _tabController.index);
        }
      });
    Future.microtask(() async {
      await ref.read(todoNotifierProvider.notifier).loadInitial();
      await ref.read(authNotifierProvider.notifier).refreshProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _keywordCtrl.dispose();
    _fullNameCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  TodoQueryEntity _buildQuery() {
    return TodoQueryEntity(
      isCompleted: _isCompleted,
      priority: _priority,
      categoryId: _categoryId,
      keyword: _keywordCtrl.text.trim().isEmpty
          ? null
          : _keywordCtrl.text.trim(),
      dueFrom: _dueFrom,
      dueTo: _dueTo,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
      page: _page,
      pageSize: _pageSize,
    );
  }

  Future<void> _search({int? page}) async {
    if (page != null) {
      _page = page;
    }
    await ref.read(todoNotifierProvider.notifier).search(_buildQuery());
  }

  Future<void> _pickDate({required bool forFrom}) async {
    final current = forFrom ? _dueFrom : _dueTo;
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: current ?? DateTime.now(),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (forFrom) {
        _dueFrom = picked;
      } else {
        _dueTo = picked;
      }
    });
  }

  Future<void> _showTodoForm({TodoEntity? editing}) async {
    final state = ref.read(todoNotifierProvider);
    final categories = state.categories;
    final titleCtrl = TextEditingController(text: editing?.title ?? '');
    final descCtrl = TextEditingController(text: editing?.description ?? '');
    DateTime? due = editing?.dueDate;
    int selectedPriority = _priorityFromLabel(editing?.priority);
    String? selectedCategoryId = editing?.categoryId;
    bool selectedCompleted = editing?.isCompleted ?? false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: _glassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      editing == null ? 'Add Todo' : 'Edit Todo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      minLines: 2,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      initialValue: selectedPriority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      borderRadius: BorderRadius.circular(16),
                      menuMaxHeight: 260,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Low')),
                        DropdownMenuItem(value: 1, child: Text('Medium')),
                        DropdownMenuItem(value: 2, child: Text('High')),
                      ],
                      onChanged: (value) {
                        setModalState(() => selectedPriority = value ?? 1);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String?>(
                      initialValue: selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Category'),
                      borderRadius: BorderRadius.circular(16),
                      menuMaxHeight: 300,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('No category'),
                        ),
                        ...categories.map(
                          (cat) => DropdownMenuItem<String?>(
                            value: cat.id,
                            child: Text(cat.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setModalState(() => selectedCategoryId = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    if (editing != null)
                      SwitchListTile.adaptive(
                        title: const Text('Completed'),
                        value: selectedCompleted,
                        onChanged: (value) {
                          setModalState(() => selectedCompleted = value);
                        },
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            due == null
                                ? 'No due date'
                                : 'Due: ${due!.toLocal().toString().split(' ').first}',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              initialDate: due ?? DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() => due = picked);
                            }
                          },
                          child: const Text('Pick date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AddTodoButton(
                      idleLabel: editing == null ? 'Save Todo' : 'Update Todo',
                      addedLabel: editing == null ? 'Saved' : 'Updated',
                      onAdd: () async {
                        final title = titleCtrl.text.trim();
                        final desc = descCtrl.text.trim();
                        if (title.isEmpty || desc.isEmpty) {
                          return;
                        }

                        if (editing == null) {
                          await ref
                              .read(todoNotifierProvider.notifier)
                              .addTodo(
                                title: title,
                                description: desc,
                                priority: selectedPriority,
                                dueDate: due,
                                categoryId: selectedCategoryId,
                              );
                        } else {
                          await ref
                              .read(todoNotifierProvider.notifier)
                              .editTodo(
                                id: editing.id,
                                title: title,
                                description: desc,
                                priority: selectedPriority,
                                dueDate: due,
                                categoryId: selectedCategoryId,
                                isCompleted: selectedCompleted,
                              );
                        }

                        if (!sheetContext.mounted) {
                          return;
                        }
                        Navigator.of(sheetContext).pop();
                        await _search(page: 1);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showCategoryForm({CategoryEntity? editing}) async {
    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    String selectedIconKey = _normalizeIconKey(editing?.icon);
    Color selectedColor =
        _parseHexColor(editing?.colorHex) ?? _presetColors.first;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: _glassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        editing == null ? 'Add Category' : 'Edit Category',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Category name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Pick icon'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: GridView.builder(
                        itemCount: _iconOptions.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                        itemBuilder: (context, index) {
                          final option = _iconOptions[index];
                          final selected = option.key == selectedIconKey;
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setModalState(() => selectedIconKey = option.key);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: selected
                                    ? selectedColor.withValues(alpha: 0.18)
                                    : Colors.white.withValues(alpha: 0.6),
                                border: Border.all(
                                  color: selected
                                      ? selectedColor
                                      : Colors.blueGrey.withValues(alpha: 0.22),
                                  width: selected ? 1.8 : 1,
                                ),
                              ),
                              child: Icon(
                                option.icon,
                                color: selected
                                    ? selectedColor
                                    : Colors.blueGrey.shade700,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Pick color'),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await _pickColorAdvanced(
                              selectedColor,
                            );
                            if (picked == null) {
                              return;
                            }
                            setModalState(() => selectedColor = picked);
                          },
                          icon: const Icon(Icons.palette_outlined),
                          label: const Text('More colors'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presetColors.map((color) {
                        final selected = color.value == selectedColor.value;
                        return InkWell(
                          onTap: () {
                            setModalState(() => selectedColor = color);
                          },
                          borderRadius: BorderRadius.circular(999),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            width: selected ? 36 : 30,
                            height: selected ? 36 : 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              border: Border.all(
                                color: selected ? Colors.black : Colors.white,
                                width: selected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.45),
                                  blurRadius: selected ? 14 : 6,
                                  spreadRadius: selected ? 2 : 0,
                                ),
                              ],
                            ),
                            child: selected
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selectedColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selectedColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: selectedColor,
                            child: Icon(
                              _iconFromKey(selectedIconKey),
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              nameCtrl.text.trim().isEmpty
                                  ? 'Category preview'
                                  : nameCtrl.text.trim(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            _colorToHex(selectedColor),
                            style: TextStyle(
                              color: Colors.blueGrey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            return;
                          }

                          if (editing == null) {
                            await ref
                                .read(todoNotifierProvider.notifier)
                                .addCategory(
                                  name: name,
                                  icon: selectedIconKey,
                                  colorHex: _colorToHex(selectedColor),
                                );
                          } else {
                            await ref
                                .read(todoNotifierProvider.notifier)
                                .editCategory(
                                  id: editing.id,
                                  name: name,
                                  icon: selectedIconKey,
                                  colorHex: _colorToHex(selectedColor),
                                );
                          }

                          if (!sheetContext.mounted) {
                            return;
                          }
                          Navigator.of(sheetContext).pop();
                        },
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: Text(
                          editing == null
                              ? 'Create category'
                              : 'Update category',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Color?> _pickColorAdvanced(Color initialColor) async {
    Color temp = initialColor;
    return showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose any color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: temp,
              onColorChanged: (next) => temp = next,
              enableAlpha: false,
              displayThumbColor: true,
              pickerAreaHeightPercent: 0.7,
              labelTypes: const [],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(temp),
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTodoDetail(TodoEntity todo) async {
    await ref.read(todoNotifierProvider.notifier).loadDetail(todo.id);
    if (!mounted) {
      return;
    }
    final detail = ref.read(todoNotifierProvider).detail;
    if (detail == null) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: _glassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detail.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(detail.description),
              const SizedBox(height: 8),
              Text('Priority: ${detail.priority}'),
              Text('Completed: ${detail.isCompleted ? 'Yes' : 'No'}'),
              Text('Category: ${detail.categoryName ?? 'No category'}'),
              Text(
                'Due: ${detail.dueDate?.toLocal().toString().split(' ').first ?? 'None'}',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showTodoForm(editing: detail);
                      },
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(todoNotifierProvider.notifier)
                            .toggle(detail.id);
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).pop();
                        await _search();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Toggle status'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _priorityFromLabel(String? label) {
    switch ((label ?? '').toLowerCase()) {
      case 'low':
        return 0;
      case 'high':
        return 2;
      default:
        return 1;
    }
  }

  String _normalizeIconKey(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return _iconOptions.first.key;
    }

    final value = raw.trim().toLowerCase();
    for (final option in _iconOptions) {
      if (option.key == value) {
        return option.key;
      }
    }

    return _iconOptions.first.key;
  }

  IconData _iconFromKey(String? key) {
    final normalized = _normalizeIconKey(key);
    for (final option in _iconOptions) {
      if (option.key == normalized) {
        return option.icon;
      }
    }
    return Icons.category_outlined;
  }

  Color? _parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) {
      return null;
    }
    final cleaned = hex.replaceAll('#', '').trim();
    if (cleaned.length != 6) {
      return null;
    }
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) {
      return null;
    }
    return Color(0xFF000000 | value);
  }

  String _colorToHex(Color color) {
    final rgb = color.value & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).toUpperCase().padLeft(6, '0')}';
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withValues(alpha: 0.78),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.lightBlue.withValues(alpha: 0.16),
                blurRadius: 24,
                spreadRadius: 3,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _liquidBackground({required Widget child}) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD9EEFF), Color(0xFFF7FBFF), Color(0xFFE7F4FF)],
            ),
          ),
        ),
        Positioned(
          left: -60,
          top: -20,
          child: _bubble(size: 180, color: const Color(0xFF96D8FF)),
        ),
        Positioned(
          right: -50,
          top: 140,
          child: _bubble(size: 140, color: const Color(0xFFBEE8FF)),
        ),
        Positioned(
          left: 60,
          bottom: -70,
          child: _bubble(size: 220, color: const Color(0xFFD7F2FF)),
        ),
        SafeArea(child: child),
      ],
    );
  }

  Widget _bubble({required double size, required Color color}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 2300),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.55),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 40,
              spreadRadius: 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    String? subtitle,
    IconData? icon,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: const Color(0xFF1D4ED8)),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.blueGrey.shade700,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.23),
              Colors.white.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.blueGrey.shade700, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _waterTab({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    final baseColor = isActive
        ? const Color(0xFF2D9DF0)
        : const Color(0xFF8DBFDB);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [
                  const Color(0xFFEEFAFF),
                  const Color(0xFFC9ECFF),
                  const Color(0xFF99D9FF),
                ]
              : [Colors.white.withValues(alpha: 0.9), const Color(0xFFEAF6FF)],
        ),
        border: Border.all(
          color: isActive
              ? const Color(0xFF8BD2FF).withValues(alpha: 0.95)
              : const Color(0xFFC5E6FA).withValues(alpha: 0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: isActive ? 0.34 : 0.16),
            blurRadius: isActive ? 18 : 10,
            spreadRadius: isActive ? 1.3 : 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 6,
            top: -3,
            child: Container(
              width: isActive ? 16 : 12,
              height: isActive ? 16 : 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFBDE7FF)],
                  stops: [0.2, 1],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF90D6FF,
                    ).withValues(alpha: isActive ? 0.6 : 0.35),
                    blurRadius: isActive ? 9 : 5,
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? const Color(0xFF0F4D77)
                    : const Color(0xFF4D7C99),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isActive
                      ? const Color(0xFF0F4D77)
                      : const Color(0xFF4D7C99),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final categoriesById = {
      for (final category in todoState.categories) category.id: category,
    };
    final items = todoState.page?.items ?? const [];

    if (authState.profile != null && _fullNameCtrl.text.isEmpty) {
      _fullNameCtrl.text = authState.profile!.fullName;
      _avatarCtrl.text = authState.profile!.avatarUrl ?? '';
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('ToDoList'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(
            const Color(0xFF8DD9FF).withValues(alpha: 0.42),
          ),
          dividerColor: Colors.transparent,
          splashBorderRadius: BorderRadius.circular(24),
          onTap: (index) => setState(() => _activeTab = index),
          tabs: [
            Tab(
              child: _waterTab(
                icon: Icons.water_drop_outlined,
                label: 'Dashboard',
                isActive: _activeTab == 0,
              ),
            ),
            Tab(
              child: _waterTab(
                icon: Icons.checklist_rounded,
                label: 'Todos',
                isActive: _activeTab == 1,
              ),
            ),
            Tab(
              child: _waterTab(
                icon: Icons.grid_view_rounded,
                label: 'Categories',
                isActive: _activeTab == 2,
              ),
            ),
            Tab(
              child: _waterTab(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: _activeTab == 3,
              ),
            ),
          ],
        ),
      ),
      body: _liquidBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            RefreshIndicator(
              onRefresh: () =>
                  ref.read(todoNotifierProvider.notifier).loadInitial(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _glassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(
                          title: 'Live Overview',
                          icon: Icons.insights_rounded,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _metricCard(
                              label: 'Total',
                              value: '${todoState.stats?.total ?? 0}',
                              color: const Color(0xFF2563EB),
                              icon: Icons.layers_rounded,
                            ),
                            const SizedBox(width: 8),
                            _metricCard(
                              label: 'Done',
                              value: '${todoState.stats?.completed ?? 0}',
                              color: const Color(0xFF059669),
                              icon: Icons.check_circle_rounded,
                            ),
                            const SizedBox(width: 8),
                            _metricCard(
                              label: 'Overdue',
                              value: '${todoState.stats?.overdue ?? 0}',
                              color: const Color(0xFFDC2626),
                              icon: Icons.schedule_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Builder(
                          builder: (_) {
                            final total = (todoState.stats?.total ?? 0)
                                .toDouble();
                            final done = (todoState.stats?.completed ?? 0)
                                .toDouble();
                            final progress = total <= 0
                                ? 0.0
                                : (done / total).clamp(0, 1).toDouble();
                            return Row(
                              children: [
                                SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CircularProgressIndicator(
                                        value: progress,
                                        strokeWidth: 8,
                                        backgroundColor: Colors.blueGrey
                                            .withValues(alpha: 0.16),
                                      ),
                                      Center(
                                        child: Text(
                                          '${(progress * 100).round()}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 10,
                                    borderRadius: BorderRadius.circular(999),
                                    backgroundColor: Colors.blueGrey.withValues(
                                      alpha: 0.18,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _glassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(
                          title: 'By Category',
                          icon: Icons.category_outlined,
                        ),
                        const SizedBox(height: 10),
                        if ((todoState.stats?.byCategory ?? const []).isEmpty)
                          const Text('No category stats yet')
                        else
                          ...todoState.stats!.byCategory.map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white.withValues(alpha: 0.62),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      size: 9,
                                      color: Color(0xFF3B82F6),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(item.categoryName)),
                                    Text(
                                      '${item.count}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            RefreshIndicator(
              onRefresh: () => _search(page: _page),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _glassCard(
                    child: Column(
                      children: [
                        TextField(
                          controller: _keywordCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Keyword',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<bool?>(
                                initialValue: _isCompleted,
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                ),
                                borderRadius: BorderRadius.circular(16),
                                menuMaxHeight: 220,
                                items: const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('All'),
                                  ),
                                  DropdownMenuItem(
                                    value: false,
                                    child: Text('Open'),
                                  ),
                                  DropdownMenuItem(
                                    value: true,
                                    child: Text('Completed'),
                                  ),
                                ],
                                onChanged: (value) =>
                                    setState(() => _isCompleted = value),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<int?>(
                                initialValue: _priority,
                                decoration: const InputDecoration(
                                  labelText: 'Priority',
                                ),
                                borderRadius: BorderRadius.circular(16),
                                menuMaxHeight: 240,
                                items: const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('All'),
                                  ),
                                  DropdownMenuItem(
                                    value: 0,
                                    child: Text('Low'),
                                  ),
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text('Medium'),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Text('High'),
                                  ),
                                ],
                                onChanged: (value) =>
                                    setState(() => _priority = value),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                initialValue: _categoryId,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                ),
                                borderRadius: BorderRadius.circular(16),
                                menuMaxHeight: 320,
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('All'),
                                  ),
                                  ...todoState.categories.map(
                                    (cat) => DropdownMenuItem<String?>(
                                      value: cat.id,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 11,
                                            backgroundColor:
                                                _parseHexColor(cat.colorHex) ??
                                                Colors.blueGrey,
                                            child: Icon(
                                              _iconFromKey(cat.icon),
                                              size: 13,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(cat.name),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) =>
                                    setState(() => _categoryId = value),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _sortBy,
                                decoration: const InputDecoration(
                                  labelText: 'Sort by',
                                ),
                                borderRadius: BorderRadius.circular(16),
                                menuMaxHeight: 260,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'createdAt',
                                    child: Text('Created'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'updatedAt',
                                    child: Text('Updated'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'title',
                                    child: Text('Title'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'priority',
                                    child: Text('Priority'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'dueDate',
                                    child: Text('Due Date'),
                                  ),
                                ],
                                onChanged: (value) => setState(
                                  () => _sortBy = value ?? 'createdAt',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate(forFrom: true),
                                icon: const Icon(Icons.event_available_rounded),
                                label: Text(
                                  _dueFrom == null
                                      ? 'Due from'
                                      : _dueFrom!
                                            .toLocal()
                                            .toString()
                                            .split(' ')
                                            .first,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate(forFrom: false),
                                icon: const Icon(Icons.event_busy_rounded),
                                label: Text(
                                  _dueTo == null
                                      ? 'Due to'
                                      : _dueTo!
                                            .toLocal()
                                            .toString()
                                            .split(' ')
                                            .first,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(
                                    value: 'desc',
                                    label: Text('Desc'),
                                  ),
                                  ButtonSegment(
                                    value: 'asc',
                                    label: Text('Asc'),
                                  ),
                                ],
                                selected: {_sortOrder},
                                onSelectionChanged: (next) {
                                  setState(() => _sortOrder = next.first);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () => _search(page: 1),
                              icon: const Icon(Icons.filter_alt_rounded),
                              label: const Text('Apply'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _showTodoForm(),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('New'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: todoState.loading
                        ? Column(
                            key: const ValueKey('loading'),
                            children: List.generate(
                              3,
                              (index) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                height: 78,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          )
                        : Column(
                            key: ValueKey('items-${items.length}'),
                            children: items
                                .map(
                                  (todo) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _glassCard(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(18),
                                        onTap: () => _showTodoDetail(todo),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Builder(
                                              builder: (_) {
                                                final category =
                                                    categoriesById[todo
                                                        .categoryId];
                                                final categoryColor =
                                                    _parseHexColor(
                                                      category?.colorHex,
                                                    ) ??
                                                    Colors.blueGrey;
                                                final categoryIcon =
                                                    _iconFromKey(
                                                      category?.icon,
                                                    );
                                                return Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      margin:
                                                          const EdgeInsets.only(
                                                            right: 8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: categoryColor,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: categoryColor
                                                                .withValues(
                                                                  alpha: 0.55,
                                                                ),
                                                            blurRadius: 8,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Icon(
                                                      categoryIcon,
                                                      size: 16,
                                                      color: categoryColor,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      category?.name ??
                                                          'No category',
                                                      style: TextStyle(
                                                        color: categoryColor,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    todo.title,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    todo.isCompleted
                                                        ? Icons
                                                              .check_circle_rounded
                                                        : Icons
                                                              .radio_button_unchecked_rounded,
                                                  ),
                                                  onPressed: () async {
                                                    await ref
                                                        .read(
                                                          todoNotifierProvider
                                                              .notifier,
                                                        )
                                                        .toggle(todo.id);
                                                    await _search();
                                                  },
                                                ),
                                              ],
                                            ),
                                            Text(todo.description),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                Chip(
                                                  avatar: Icon(
                                                    _priorityFromLabel(
                                                              todo.priority,
                                                            ) ==
                                                            2
                                                        ? Icons
                                                              .priority_high_rounded
                                                        : _priorityFromLabel(
                                                                todo.priority,
                                                              ) ==
                                                              1
                                                        ? Icons.flag_outlined
                                                        : Icons
                                                              .keyboard_double_arrow_down_rounded,
                                                    size: 16,
                                                  ),
                                                  label: Text(
                                                    'Priority ${todo.priority}',
                                                  ),
                                                ),
                                                Chip(
                                                  label: Text(
                                                    todo.dueDate == null
                                                        ? 'No due date'
                                                        : 'Due ${todo.dueDate!.toLocal().toString().split(' ').first}',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () =>
                                                      _showTodoForm(
                                                        editing: todo,
                                                      ),
                                                  icon: const Icon(
                                                    Icons.edit_rounded,
                                                  ),
                                                  label: const Text('Edit'),
                                                ),
                                                const SizedBox(width: 8),
                                                TextButton.icon(
                                                  onPressed: () async {
                                                    await ref
                                                        .read(
                                                          todoNotifierProvider
                                                              .notifier,
                                                        )
                                                        .remove(todo.id);
                                                    await _search();
                                                  },
                                                  icon: const Icon(
                                                    Icons.delete_rounded,
                                                  ),
                                                  label: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 8),
                  _glassCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: (todoState.page?.page ?? 1) > 1
                                ? () => _search(
                                    page: (todoState.page?.page ?? 1) - 1,
                                  )
                                : null,
                            icon: const Icon(Icons.chevron_left_rounded),
                            label: const Text('Prev'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Page ${todoState.page?.page ?? 1}/${todoState.page?.totalPages ?? 1}',
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                (todoState.page?.page ?? 1) <
                                    (todoState.page?.totalPages ?? 1)
                                ? () => _search(
                                    page: (todoState.page?.page ?? 1) + 1,
                                  )
                                : null,
                            icon: const Icon(Icons.chevron_right_rounded),
                            label: const Text('Next'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            RefreshIndicator(
              onRefresh: () =>
                  ref.read(todoNotifierProvider.notifier).loadCategories(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _glassCard(
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manage Categories',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showCategoryForm(),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...todoState.categories.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _glassCard(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _showCategoryForm(editing: category),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    _parseHexColor(category.colorHex) ??
                                    Colors.blueGrey,
                                child: Icon(
                                  _iconFromKey(category.icon),
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      category.colorHex ?? '',
                                      style: TextStyle(
                                        color: Colors.blueGrey.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Delete category',
                                onPressed: () async {
                                  await ref
                                      .read(todoNotifierProvider.notifier)
                                      .removeCategory(category.id);
                                },
                                icon: const Icon(Icons.delete_rounded),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            RefreshIndicator(
              onRefresh: () =>
                  ref.read(authNotifierProvider.notifier).refreshProfile(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _glassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.profile?.fullName ??
                              authState.profile?.userName ??
                              'Profile',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Username: ${authState.profile?.userName ?? ''}'),
                        Text('Email: ${authState.profile?.email ?? ''}'),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _fullNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _avatarCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Avatar URL',
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: authState.loading
                              ? null
                              : () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  final ok = await ref
                                      .read(authNotifierProvider.notifier)
                                      .updateProfile(
                                        fullName: _fullNameCtrl.text.trim(),
                                        avatarUrl: _avatarCtrl.text.trim(),
                                      );
                                  if (!mounted) {
                                    return;
                                  }
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        ok
                                            ? 'Profile updated'
                                            : 'Update failed',
                                      ),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Save profile'),
                        ),
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

class _CategoryIconOption {
  const _CategoryIconOption(this.key, this.icon);

  final String key;
  final IconData icon;
}
