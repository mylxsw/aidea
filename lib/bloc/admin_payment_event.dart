part of 'admin_payment_bloc.dart';

@immutable
sealed class AdminPaymentEvent {}

class AdminPaymentHistoriesLoadEvent extends AdminPaymentEvent {
  final int page;
  final int perPage;
  final String? keyword;

  AdminPaymentHistoriesLoadEvent({
    this.page = 1,
    this.perPage = 20,
    this.keyword,
  });
}
