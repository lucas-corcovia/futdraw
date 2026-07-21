// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:futdraw/controllers/auth_controller.dart';
import 'package:futdraw/controllers/configurations_controller.dart';
import 'package:futdraw/models/enums/generation_algorithm.dart';
import 'package:futdraw/models/enums/theme_color.dart';
import 'package:futdraw/utils/extensions.dart';
import 'package:futdraw/views/auth/login_view.dart';
import 'package:provider/provider.dart';

class DrawerComponent extends StatelessWidget {
  const DrawerComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      elevation: 0,
      child: SafeArea(
        child: Consumer<ConfigurationsController>(
          builder: (context, controller, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DrawerHeader(controller: controller),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _SectionLabel(label: 'APARÊNCIA'),
                        _ColorPickerGrid(controller: controller),
                        const SizedBox(height: 4),
                        _DarkModeToggleTile(controller: controller),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(height: 32),
                        ),
                        const _SectionLabel(label: 'CONFIGURAÇÕES'),
                        _AlgorithmSelector(controller: controller),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                const _LogoutTile(),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final ConfigurationsController controller;

  const _DrawerHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, scheme.primary],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.onPrimary.withValues(alpha: 0.15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FutDraw',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: scheme.onPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Sorteio de Times',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 12,
                    color: scheme.onPrimary.withValues(alpha: 0.8),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _ColorPickerGrid extends StatelessWidget {
  final ConfigurationsController controller;

  const _ColorPickerGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: ThemeColor.values.length,
        itemBuilder: (context, index) {
          final color = ThemeColor.values[index];
          final isSelected = controller.configuration.themeColor == color;
          return _ColorCircle(
            color: color,
            isSelected: isSelected,
            onTap: () => controller.setTheme(color),
          );
        },
      ),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  final ThemeColor color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorCircle({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: color.label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.seed,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.seed.withValues(alpha: 0.55),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: isSelected
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
              : null,
        ),
      ),
    );
  }
}

class _DarkModeToggleTile extends StatelessWidget {
  final ConfigurationsController controller;

  const _DarkModeToggleTile({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = controller.configuration.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
            key: ValueKey(isDark),
            color: isDark
                ? const Color(0xFF818CF8)
                : const Color(0xFFFBBF24),
          ),
        ),
        title: const Text('Modo Escuro'),
        trailing: Switch(
          value: isDark,
          onChanged: (_) => controller.toggleDarkMode(),
        ),
      ),
    );
  }
}

class _AlgorithmSelector extends StatelessWidget {
  final ConfigurationsController controller;

  const _AlgorithmSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: SegmentedButton<GenerationAlgorithm>(
        segments: const [
          ButtonSegment(
            value: GenerationAlgorithm.balanced,
            label: Text('Balanceado'),
            icon: Icon(Icons.balance, size: 16),
          ),
          ButtonSegment(
            value: GenerationAlgorithm.snakeDraft,
            label: Text('Snake Draft'),
            icon: Icon(Icons.swap_vert, size: 16),
          ),
        ],
        selected: {controller.configuration.generationAlgorithm},
        onSelectionChanged: (selection) {
          if (selection.isNotEmpty) {
            controller.setAlgorithm(selection.first);
          }
        },
        style: SegmentedButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: 'Kanit',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Theme.of(
          context,
        ).colorScheme.errorContainer.withValues(alpha: 0.3),
        leading: Icon(
          Icons.logout_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(
          'Sair',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () async {
          await context.read<AuthController>().logout();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginView()),
            (_) => false,
          );
        },
      ),
    );
  }
}
