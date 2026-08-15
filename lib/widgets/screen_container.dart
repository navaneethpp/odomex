import 'package:flutter/material.dart';

class ScreenContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showBackButton;

  //Floating Action Button
  final bool showFloatingButton;
  final IconData? floatingActionButtonIcon;
  final VoidCallback? onFloatingButtonPressed;
  final String? floatingButtonTooltip;

  const ScreenContainer({
    super.key,
    required this.title,
    required this.child,
    this.showBackButton = true,
    this.showFloatingButton = false,
    this.floatingActionButtonIcon,
    this.onFloatingButtonPressed,
    this.floatingButtonTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        child: child,
      ),
      floatingActionButton: showFloatingButton
          ? FloatingActionButton(
              onPressed: onFloatingButtonPressed,
              tooltip: floatingButtonTooltip,
              child: Icon(
                floatingActionButtonIcon ?? Icons.add,
              ),
            )
          : null,
    );
  }
}
