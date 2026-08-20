import 'dart:math';

class IdempotencyKeyGenerator {
  IdempotencyKeyGenerator._();

  static const String _characters =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      'abcdefghijklmnopqrstuvwxyz'
      '0123456789';

  static final Random _random = Random.secure();

  /// Generates exactly 128 cryptographically secure random characters.
  static String generate() {
    return List.generate(
      128,
      (_) => _characters[_random.nextInt(_characters.length)],
    ).join();
  }
}