import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:askaide/page/component/windows.dart';
import 'package:askaide/repo/api/payment.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'web/payment_element.dart' if (dart.library.js) 'web/payment_element_web.dart';

class WebPaymentResult extends StatefulWidget {
  final String paymentId;
  final String? action;
  const WebPaymentResult({
    super.key,
    required this.paymentId,
    this.action,
  });

  @override
  State<WebPaymentResult> createState() => _WebPaymentResultState();
}

class _WebPaymentResultState extends State<WebPaymentResult> {
  PaymentStatus? paymentStatus;
  DateTime startTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    updatePaymentStatus();
  }

  updatePaymentStatus() {
    if (!context.mounted) {
      return;
    }

    if (DateTime.now().difference(startTime).inSeconds > 60) {
      setState(() {
        paymentStatus = PaymentStatus(false, note: '查询超时');
      });
      return;
    }

    APIServer().queryPaymentStatus(widget.paymentId).then((value) {
      if (!value.success) {
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            updatePaymentStatus();
          }
        });
      } else {
        setState(() {
          paymentStatus = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;
    return WindowFrameWidget(
      backgroundColor: customColors.backgroundColor,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('支付结果'),
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: customColors.weakLinkColor,
            ),
            onPressed: () {
              if (widget.action != null && widget.action == 'close') {
                closeWindow();
              } else {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/payment');
                }
              }
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buildResult(),
          ),
        ),
      ),
    );
  }

  List<Widget> buildResult() {
    if (paymentStatus == null) {
      return const [
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text('正在查询支付结果'),
      ];
    }

    if (!paymentStatus!.success) {
      return [
        const Icon(
          Icons.error,
          color: Colors.red,
          size: 100,
        ),
        Text(paymentStatus!.note ?? '支付失败'),
      ];
    }

    return [
      const Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 100,
      ),
      const Text(
        '支付成功',
        style: TextStyle(fontSize: 24),
      ),
    ];
  }
}
