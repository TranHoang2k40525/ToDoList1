import 'package:flutter/material.dart';

class AddTodoButton extends StatefulWidget {
  const AddTodoButton({
    super.key,
    required this.onAdd,
    this.idleLabel = 'Add',
    this.addedLabel = 'Added',
  });

  final Future<void> Function() onAdd;
  final String idleLabel;
  final String addedLabel;

  @override
  State<AddTodoButton> createState() => _AddTodoButtonState();
}

class _AddTodoButtonState extends State<AddTodoButton> {
  bool _isSubmitting = false;
  bool _isAdded = false;

  Future<void> _handleTap() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onAdd();
      if (!mounted) {
        return;
      }
      setState(() {
        _isAdded = true;
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _isSubmitting
        ? 'Adding...'
        : _isAdded
            ? widget.addedLabel
            : widget.idleLabel;

    return ElevatedButton(
      key: const Key('add_todo_button'),
      onPressed: _isSubmitting ? null : _handleTap,
      child: Text(label),
    );
  }
}
