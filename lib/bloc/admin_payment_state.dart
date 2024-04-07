part of 'admin_payment_bloc.dart';

@immutable
sealed class AdminPaymentState {}

final class AdminPaymentInitial extends AdminPaymentState {}

class AdminPaymentOperationResult extends AdminPaymentState {
  final bool success;
  final String message;

  AdminPaymentOperationResult(this.success, this.message);
}

class AdminPaymentHistoriesLoaded extends AdminPaymentState {
  final PagedData<AdminPaymentHistory> histories;

  AdminPaymentHistoriesLoaded(this.histories);
}
