import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentService {
  /// Returns true when the Stripe PaymentSheet completes (use card 4242 4242 4242 4242).
  Future<bool> pay(double amountUsd) async {
    final res = await FirebaseFunctions.instance
        .httpsCallable('createPaymentIntent')
        .call({'amount': amountUsd});
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: res.data['clientSecret'],
        merchantDisplayName: 'اثرنا',
      ),
    );
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException {
      return false; // cancelled / failed
    }
  }
}
