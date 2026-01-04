// lib/screens/personalization/theme_selector_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/personalization_provider.dart';
import '../../models/theme_model.dart';

class ThemeSelectorScreen extends StatelessWidget {
  const ThemeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Theme')),
      body: Consumer<PersonalizationProvider>(
        builder: (context, provider, child) {
          final currentTheme =
              provider.preferences?.preferredTheme ?? AppThemeType.ocean;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: AppThemeType.values.length,
            itemBuilder: (context, index) {
              final themeType = AppThemeType.values[index];
              final themeData = AppThemeData.getTheme(themeType);
              final isSelected = currentTheme == themeType;

              return _buildThemeCard(
                context,
                themeData,
                themeType,
                isSelected,
                () => provider.updateTheme(themeType),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    AppThemeData theme,
    AppThemeType themeType,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Theme preview
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: theme.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(theme.emoji, style: const TextStyle(fontSize: 48)),
                      if (isSelected) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Theme name
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      theme.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
