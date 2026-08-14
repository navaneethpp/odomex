import 'package:flutter/material.dart';

class Screencontainer extends StatelessWidget {
  const Screencontainer({
    super.key,
    required this.title,
    required this.child,
    required this.showBackButton,
  });

  final String title;
  final bool showBackButton;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(title),
        leading: showBackButton
            ? IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                ),
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
    );
  }
}
