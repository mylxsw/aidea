import 'package:askaide/helper/ability.dart';
import 'package:askaide/lang/lang.dart';
import 'package:dart_openai/openai.dart';

Object resolveErrorMessage(dynamic e) {
  if (e is RequestFailedException) {
    final msg = resolveHTTPStatusCode(e.statusCode);
    if (msg != null) {
      return msg;
    }

    return e.message;
  }

  return e.toString();
}

Object? resolveHTTPStatusCode(int statusCode) {
  switch (statusCode) {
    case 400:
      return const LanguageText('请求参数错误');
    case 401:
      if (Ability().supportLocalOpenAI()) {
        return const LanguageText(AppLocale.openAIAuthFailed);
      }

      if (Ability().supportAPIServer()) {
        return const LanguageText(AppLocale.accountNeedReSignin,
            action: 're-signin');
      }
      return const LanguageText(AppLocale.signInRequired, action: 'sign-in');

    case 451:
      return const LanguageText(AppLocale.modelNotValid);
    case 402:
      return const LanguageText(AppLocale.quotaExceeded, action: 'payment');
    case 500:
      return const LanguageText(AppLocale.internalServerError);
    case 502:
      return const LanguageText(AppLocale.badGateway);
  }

  return null;
}
