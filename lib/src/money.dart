/// Divides [numerator] by [denominator] rounding half-up, as Finance
/// requires for every money amount. Both values must be non-negative.
int roundHalfUp(int numerator, int denominator) =>
    (numerator * 2 + denominator) ~/ (denominator * 2);

/// Returns [basisPoints] of [cents] rounded half-up (1500 bps = 15%).
int percentOfCents(int cents, int basisPoints) =>
    roundHalfUp(cents * basisPoints, 10000);
