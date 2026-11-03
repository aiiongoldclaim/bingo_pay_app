import '../../../core/di/injection.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/error/failures.dart';
import '../../../core/storage/preferences_service.dart';
import '../../scanner/data/tvs_qr_datasource.dart';

typedef Invite = ({String code, String channel});

// An invite code that arrived by link (/join?ref=CODE) or by QR (…&ch=QR),
// kept until the user is signed in to add it to their account.
class PendingInvite {
  PendingInvite({PreferencesService? prefs, TvsQrDataSource? api})
    : _prefs = prefs ?? getIt<PreferencesService>(),
      _api = api ?? getIt<TvsQrDataSource>();

  final PreferencesService _prefs;
  final TvsQrDataSource _api;

  // One add at a time: signing in and the landing page can ask together.
  static Future<String?>? _adding;

  // The code and channel of an invite link, or null when `uri` is not one.
  // The server's links carry `ref`; `code` is accepted too.
  static Invite? parse(Uri uri) {
    if (uri.path.replaceFirst(RegExp(r'/+$'), '') != '/join') return null;
    final q = uri.queryParameters;
    final code = (q['ref'] ?? q['code'] ?? '').trim().toUpperCase();
    if (code.isEmpty) return null;
    return (code: code, channel: q['ch'] == 'QR' ? 'QR' : 'LINK');
  }

  Future<void> save(Invite invite) =>
      _prefs.setPendingInvite(invite.code, invite.channel);

  // Adds the saved code to the signed-in account. Null once added (or when
  // none is saved), else why it could not be. A refusal (own code, already
  // joined, too long since sign-up) drops the code; a network failure keeps
  // it for the next sign-in.
  Future<String?> add() =>
      _adding ??= _add().whenComplete(() => _adding = null);

  Future<String?> _add() async {
    final saved = _prefs.getPendingInvite();
    if (saved == null || saved.length != 2) return null;
    try {
      await _api.applyReferralCode(saved[0], channel: saved[1]);
      await _prefs.clearPendingInvite();
      return null;
    } catch (e) {
      final failure = ErrorHandler.mapObjectToFailure(e);
      if (failure is! NetworkFailure) await _prefs.clearPendingInvite();
      return failure.message;
    }
  }
}
