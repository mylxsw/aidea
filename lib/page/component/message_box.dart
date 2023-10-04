import 'package:flutter/material.dart';

class MessageBox extends StatelessWidget {
  final String message;
  final MessageBoxType type;
  const MessageBox({super.key, required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: type.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: type.borderColor,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      child: Theme(
        data: ThemeData(
          iconTheme: IconThemeData(
            color: type.textColor,
          ),
          primaryTextTheme: TextTheme(
            bodyMedium: TextStyle(
              color: type.textColor,
            ),
            bodySmall: TextStyle(
              color: type.textColor,
            ),
            bodyLarge: TextStyle(
              color: type.textColor,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (type.iconData != null)
              Icon(
                type.iconData,
                color: type.textColor,
                size: 16,
              ),
            if (type.iconData != null) const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: type.textColor,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBoxType {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData? iconData;

  const MessageBoxType({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    this.iconData,
  });

  static const MessageBoxType info = MessageBoxType(
    backgroundColor: Color.fromARGB(255, 232, 245, 233),
    textColor: Color.fromARGB(255, 72, 121, 75),
    borderColor: Color.fromARGB(255, 46, 125, 50),
    iconData: Icons.info,
  );

  static const MessageBoxType warning = MessageBoxType(
    backgroundColor: Color(0xFFFFFDE7),
    textColor: Color(0xFFE65100),
    borderColor: Color(0xFFE65100),
    iconData: Icons.warning,
  );

  static const MessageBoxType error = MessageBoxType(
    backgroundColor: Color(0xFFFFEBEE),
    textColor: Color(0xFFC62828),
    borderColor: Color(0xFFC62828),
    iconData: Icons.error,
  );

  static const MessageBoxType success = MessageBoxType(
    backgroundColor: Color(0xFFE0F2F1),
    textColor: Color(0xFF00695C),
    borderColor: Color(0xFF00695C),
    iconData: Icons.check_circle,
  );
}
