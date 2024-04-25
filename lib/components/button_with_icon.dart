import 'package:flutter/material.dart';

class ButtonWithIcon extends StatelessWidget {
  final Icon icon;
  final String label;
  final VoidCallback onPressed;

  const ButtonWithIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(label,
          style: const TextStyle(fontSize: 18, color: Colors.white)),
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll<Color>(Colors.grey.shade800),
        minimumSize: MaterialStateProperty.all(const Size(250, 50)),
      ),
    );
  }
}
