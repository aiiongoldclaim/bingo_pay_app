import 'package:encrypt/encrypt.dart';

/// Client-side obfuscation only: keeps the raw email out of the QR payload
/// so a casual scan doesn't reveal it in plain text. Key is bundled with the
/// app, so this is not a substitute for server-side encryption.
class EmailQrCodec {
  static final _key = Key.fromUtf8('BingoPayVendorQrEncryptionKey32!');
  static final _iv = IV.fromUtf8('BingoPayQrCodeIV');
  static final _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  static String encrypt(String email) =>
      _encrypter.encrypt(email, iv: _iv).base64;

  static String decrypt(String payload) =>
      _encrypter.decrypt64(payload, iv: _iv);
}
