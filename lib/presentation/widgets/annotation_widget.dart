import 'package:flutter/material.dart';

class AnnotationWidget extends StatefulWidget {
  final String? annotation;
  final ValueChanged<String?> onAnnotationChanged;

  const AnnotationWidget({
    super.key,
    this.annotation,
    required this.onAnnotationChanged,
  });

  @override
  State<AnnotationWidget> createState() => _AnnotationWidgetState();
}

class _AnnotationWidgetState extends State<AnnotationWidget> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.annotation ?? '');
  }

  @override
  void didUpdateWidget(AnnotationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.annotation != widget.annotation && !_isEditing) {
      _controller.text = widget.annotation ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveAnnotation() {
    final text = _controller.text.trim();
    widget.onAnnotationChanged(text.isEmpty ? null : text);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.note,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Notes personnelles',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isEditing)
          Column(
            children: [
              TextField(
                controller: _controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ajoutez vos notes sur ce vin...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _controller.text = widget.annotation ?? '';
                      setState(() => _isEditing = false);
                    },
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _saveAnnotation,
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ],
          )
        else
          InkWell(
            onTap: () => setState(() => _isEditing = true),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: widget.annotation?.isNotEmpty == true
                  ? Text(
                      widget.annotation!,
                      style: theme.textTheme.bodyMedium,
                    )
                  : Text(
                      'Touchez pour ajouter une note...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}

class AnnotationPreview extends StatelessWidget {
  final String? annotation;

  const AnnotationPreview({
    super.key,
    this.annotation,
  });

  @override
  Widget build(BuildContext context) {
    if (annotation == null || annotation!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.note,
            size: 14,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              annotation!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
