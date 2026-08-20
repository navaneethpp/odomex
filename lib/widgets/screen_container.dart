import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';

class ScreenContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showBackButton;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  const ScreenContainer({
    super.key,
    required this.title,
    required this.child,
    this.showBackButton = true,
    this.floatingActionButton,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: actions,
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
          horizontal: AppSizes.paddingLg,
          vertical: AppSizes.paddingLg,
        ),
        child: child,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
