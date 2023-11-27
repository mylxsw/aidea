import 'package:askaide/helper/ability.dart';
import 'package:askaide/lang/lang.dart';
import 'package:dart_openai/openai.dart';

Object resolveErrorMessage(dynamic e, {bool isChat = false}) {
  // TODO
  if (e is RequestFailedException) {
    final msg =
        resolveHTTPStatusCode(e.statusCode, isChat: isChat, message: e.message);
    if (msg != null) {
      return msg;
    }

    return e.message;
  }

  return e.toString();
}

Object? resolveHTTPStatusCode(int statusCode,
    {bool isChat = false, String? message}) {
  switch (statusCode) {
    case 400:
      return const LanguageText('请求参数错误');
    case 401:
      if (Ability().enableLocalOpenAI) {
        return const LanguageText(AppLocale.openAIAuthFailed);
      }

      if (Ability().enableAPIServer()) {
        return const LanguageText(AppLocale.accountNeedReSignin,
            action: 're-signin');
      }
      return const LanguageText(AppLocale.signInRequired, action: 'sign-in');
    case 404:
      if (isChat) {
        return const LanguageText(AppLocale.modelNotFound);
      }
      break;
    case 429:
      if (isChat) {
        return const LanguageText(AppLocale.tooManyRequestsOrPaymentRequired);
      }

      return const LanguageText(AppLocale.tooManyRequests);
    case 451:
      return const LanguageText(AppLocale.modelNotValid);
    case 402:
      return const LanguageText(AppLocale.quotaExceeded, action: 'payment');
    case 500:
      if (message != null && message.isNotEmpty) {
        return message;
      }

      return const LanguageText(AppLocale.internalServerError);
    case 502:
      return const LanguageText(AppLocale.badGateway);
  }

  return null;
}
