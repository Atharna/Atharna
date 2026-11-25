const { onCall, HttpsError } = require('firebase-functions/v2/https');
const stripe = require('stripe')(process.env.STRIPE_SECRET); // sk_test_...

exports.createPaymentIntent = onCall(async (req) => {
  if (!req.auth) throw new HttpsError('unauthenticated', 'Sign in first');
  const pi = await stripe.paymentIntents.create({
    amount: Math.round(req.data.amount * 100), currency: 'usd',
    automatic_payment_methods: { enabled: true },
    metadata: { uid: req.auth.uid },
  });
  return { clientSecret: pi.client_secret };
});
