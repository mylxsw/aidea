import 'package:askaide/repo/api/admin/payment.dart';
import 'package:askaide/repo/api/page.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'admin_payment_event.dart';
part 'admin_payment_state.dart';

class AdminPaymentBloc extends Bloc<AdminPaymentEvent, AdminPaymentState> {
  AdminPaymentBloc() : super(AdminPaymentInitial()) {
    on<AdminPaymentHistoriesLoadEvent>((event, emit) async {
      final histories = await APIServer().adminPaymentHistories(
        page: event.page,
        perPage: event.perPage,
        keyword: event.keyword,
      );
      emit(AdminPaymentHistoriesLoaded(histories));
    });
  }
}
