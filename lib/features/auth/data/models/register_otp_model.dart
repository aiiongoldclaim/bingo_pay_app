class RegisterOtpModel {
  final bool otpSent;
  final String email;
  final String message;
  final int? maxOtpCount;
  final int? referralCode;

  const RegisterOtpModel({
    required this.otpSent,
    required this.email,
    required this.message,
    this.maxOtpCount,
    this.referralCode,
  });

  factory RegisterOtpModel.fromJson(Map<String, dynamic> json) {
    final bingoldData =
        (json['bingold'] as Map<String, dynamic>?)?['data']
            as Map<String, dynamic>?;
    return RegisterOtpModel(
      otpSent: json['otpSent'] as bool? ?? false,
      email: json['email'] as String,
      message: json['message'] as String? ?? '',
      maxOtpCount: bingoldData?['maxOtpCount'] as int?,
      referralCode: bingoldData?['referralCode'] as int?,
    );
  }

  // resend-otp nests `data` but puts the human-readable message at the
  // top level instead of inside `data` (unlike the register response).
  factory RegisterOtpModel.fromResendJson(Map<String, dynamic> root) {
    final data = root['data'] as Map<String, dynamic>;
    final bingoldData =
        (data['bingold'] as Map<String, dynamic>?)?['data']
            as Map<String, dynamic>?;
    return RegisterOtpModel(
      otpSent: data['otpSent'] as bool? ?? false,
      email: data['email'] as String,
      message: root['message'] as String? ?? '',
      maxOtpCount: bingoldData?['maxOtpCount'] as int?,
      referralCode: bingoldData?['referralCode'] as int?,
    );
  }
}
