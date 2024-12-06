import 'package:askaide/helper/event.dart';
import 'package:askaide/page/component/chat/markdown.dart';
import 'package:askaide/page/component/theme/custom_size.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

class GlobalAlertEvent {
  String id;
  String? message;
  String type;
  List<String> pages;

  GlobalAlertEvent({
    required this.id,
    this.message,
    required this.type,
    required this.pages,
  });

  toJSON() {
    return {
      'id': id,
      'message': message,
      'type': type,
      'pages': pages,
    };
  }
}

class GlobalAlert extends StatefulWidget {
  final String pageKey;
  const GlobalAlert({super.key, required this.pageKey});

  @override
  State<GlobalAlert> createState() => _GlobalAlertState();
}

class _GlobalAlertState extends State<GlobalAlert> {
  Function? globalAlertListener;

  late GlobalAlertEvent alertEvent;

  @override
  void initState() {
    alertEvent = APIServer().globalAlertEvent;

    globalAlertListener = GlobalEvent().on('global-alert', (data) {
      final event = data as GlobalAlertEvent;
      if (event.pages.isNotEmpty && !event.pages.contains(widget.pageKey)) {
        return;
      }

      if (mounted) {
        setState(() {
          alertEvent = data;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    globalAlertListener?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (alertEvent.id == '' || alertEvent.message == null || alertEvent.message == '') {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      decoration: BoxDecoration(color: resolveBackgroundColor(), borderRadius: CustomSize.borderRadius),
      child: Markdown(
        data: alertEvent.message!,
        textStyle: const TextStyle(
          color: Colors.white,
        ),
        onUrlTap: (value) {
          if (value.startsWith("aidea-app://")) {
            var route = value.substring('aidea-app://'.length);
            context.push(route);
          } else {
            launchUrlString(value);
          }
        },
      ),
    );
  }

  Color resolveBackgroundColor() {
    switch (alertEvent.type) {
      case 'error':
      case 'warning':
        return const Color.fromARGB(255, 252, 145, 79);
      case 'info':
        return const Color.fromARGB(255, 18, 83, 135);
      default:
        return Colors.green;
    }
  }
}
