import 'package:flutter/material.dart';
import 'package:dipstore_ui/core/theme/app_theme.dart';

class GlassSection extends StatelessWidget {
  final List<Widget> children;

  const GlassSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.elevation1,
      ),
      child: Column(children: children),
    );
  }
}
