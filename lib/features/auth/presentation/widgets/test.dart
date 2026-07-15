// Standalone design mockup — not part of the app.
// ignore_for_file: unused_element, unused_element_parameter

import 'package:flutter/material.dart';

void main() => runApp(const AiionGoldApp());

class AiionGoldApp extends StatelessWidget {
  const AiionGoldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIION GOLD',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.pageBg,
        fontFamily: 'Poppins',
      ),
      home: const LoginScreen(),
    );
  }
}

class AppColors {
  static const navyDark = Color(0xFF0B1F4B);
  static const navyMid = Color(0xFF13306E);
  static const navyLight = Color(0xFF1B3C86);

  static const gold = Color(0xFFD8A93A);
  static const goldLight = Color(0xFFF3CE6B);
  static const goldDeep = Color(0xFFB8860B);

  static const pageBg = Color(0xFFF6F7FB);
  static const fieldBorder = Color(0xFFE4E7F0);
  static const iconChipBg = Color(0xFFE7F0FE);

  static const primaryBlue = Color(0xFF1E3FAE);
  static const primaryBlueDark = Color(0xFF152C86);
  static const linkBlue = Color(0xFF1D5BD6);

  static const textDark = Color(0xFF0E1B3D);
  static const textGrey = Color(0xFF6B7280);
  static const hintGrey = Color(0xFF9AA1B0);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  // bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final headerHeight = size.height * 0.44;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            child: CustomPaint(
              size: const Size(180, 160),
              painter: DotsPainter(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
              ),
            ),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [_Header(height: headerHeight)]),
          ),
        ],
      ),
    );
  }

//   Widget _buildForm() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Center(
//             child: Text(
//               'Welcome Back!',
//               style: TextStyle(
//                 fontSize: 30,
//                 fontWeight: FontWeight.w700,
//                 color: AppColors.textDark,
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Center(
//             child: Text(
//               'Login to continue to your account',
//               style: TextStyle(fontSize: 16, color: AppColors.textGrey),
//             ),
//           ),
//           const SizedBox(height: 28),
//
//           const _FieldLabel('Email'),
//           const SizedBox(height: 8),
//           _AppTextField(
//             controller: _emailCtrl,
//             hint: 'Enter your email',
//             icon: Icons.mail_outline_rounded,
//             keyboardType: TextInputType.emailAddress,
//           ),
//           const SizedBox(height: 20),
//
//           const _FieldLabel('Password'),
//           const SizedBox(height: 8),
//           _AppTextField(
//             controller: _passCtrl,
//             hint: 'Enter your password',
//             icon: Icons.lock_outline_rounded,
//             obscureText: _obscure,
//             suffix: IconButton(
//               splashRadius: 20,
//               icon: Icon(
//                 _obscure
//                     ? Icons.visibility_off_outlined
//                     : Icons.visibility_outlined,
//                 color: AppColors.hintGrey,
//               ),
//               onPressed: () => setState(() => _obscure = !_obscure),
//             ),
//           ),
//           const SizedBox(height: 12),
//
//           Align(
//             alignment: Alignment.centerRight,
//             child: GestureDetector(
//               onTap: () {},
//               child: const Text(
//                 'Forgot Password?',
//                 style: TextStyle(
//                   color: AppColors.linkBlue,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 22),
//
//           _LoginButton(onPressed: () {}),
//           const SizedBox(height: 28),
//
//           Row(
//             children: const [
//               Expanded(child: Divider(color: AppColors.fieldBorder)),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 12),
//                 child: Text(
//                   'or continue with',
//                   style: TextStyle(color: AppColors.textGrey, fontSize: 14),
//                 ),
//               ),
//               Expanded(child: Divider(color: AppColors.fieldBorder)),
//             ],
//           ),
//           const SizedBox(height: 20),
//
//           Row(
//             children: [
//               Expanded(
//                 child: _SocialButton(
//                   label: 'Google',
//                   iconWidget: const _GoogleG(),
//                   onTap: () {},
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _SocialButton(
//                   label: 'Apple',
//                   iconWidget: const Icon(
//                     Icons.apple,
//                     color: Colors.black,
//                     size: 26,
//                   ),
//                   onTap: () {},
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _SocialButton(
//                   label: 'Facebook',
//                   iconWidget: const Icon(
//                     Icons.facebook,
//                     color: Color(0xFF1877F2),
//                     size: 26,
//                   ),
//                   onTap: () {},
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 30),
//
//           Center(
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   "Don't have an account?  ",
//                   style: TextStyle(color: AppColors.textDark, fontSize: 16),
//                 ),
//                 GestureDetector(
//                   onTap: () {},
//                   child: const Text(
//                     'Register',
//                     style: TextStyle(
//                       color: AppColors.linkBlue,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 22),
//
//           Center(
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: const [
//                 Icon(
//                   Icons.verified_user_outlined,
//                   size: 20,
//                   color: AppColors.linkBlue,
//                 ),
//                 SizedBox(width: 8),
//                 Text(
//                   'Your data is safe and secure with us.',
//                   style: TextStyle(color: AppColors.textGrey, fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 30),
//         ],
//       ),
//     );
//   }
}

class _Header extends StatelessWidget {
  final double height;
  const _Header({required this.height});

  @override
  Widget build(BuildContext context) {
    // final w = MediaQuery.of(context).size.width;
    // final topPad = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipPath(
              clipper: GoldCurveClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.goldDeep,
                      AppColors.goldLight,
                      AppColors.gold,
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: ClipPath(
              clipper: NavyCurveClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.navyDark,
                      AppColors.navyMid,
                      AppColors.navyLight,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: CustomPaint(
                        size: const Size(220, 120),
                        painter: DotsPainter(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavyCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, h * 0.9461)
      ..cubicTo(
        w * 0.0550,
        h * 0.8757,
        w * 0.1295,
        h * 0.8305,
        w * 0.1850,
        h * 0.8066,
      )
      ..cubicTo(
        w * 0.4540,
        h * 0.6908,
        w * 0.7200,
        h * 0.6977,
        w * 1.0000,
        h * 0.5318,
      )
      ..lineTo(w, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class GoldCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, h * 0.9948)
      ..cubicTo(
        w * 0.0550,
        h * 0.9039,
        w * 0.1295,
        h * 0.8631,
        w * 0.1850,
        h * 0.8339,
      )
      ..cubicTo(
        w * 0.4540,
        h * 0.6924,
        w * 0.7200,
        h * 0.7023,
        w * 1.0000,
        h * 0.5568,
      )
      ..lineTo(w, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// class _LanguagePill extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.08),
//         borderRadius: BorderRadius.circular(30),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: const [
//           Icon(Icons.language, color: Colors.white, size: 20),
//           SizedBox(width: 6),
//           Text(
//             'EN',
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w600,
//               fontSize: 15,
//             ),
//           ),
//           SizedBox(width: 4),
//           Icon(
//             Icons.keyboard_arrow_down_rounded,
//             color: Colors.white,
//             size: 20,
//           ),
//         ],
//       ),
//     );
//   }
// }

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _AppTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.fieldBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.iconChipBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 16, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AppColors.hintGrey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          ?suffix,
        ],
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: const [
              Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Positioned(
                right: 20,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget iconWidget;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.iconWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.fieldBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFFEA4335),
          Color(0xFFFBBC05),
          Color(0xFF34A853),
          Color(0xFF4285F4),
        ],
        stops: [0.0, 0.35, 0.65, 1.0],
      ).createShader(rect),
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class DotsPainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double gap;

  DotsPainter({required this.color, this.dotRadius = 2.2, this.gap = 18});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double y = dotRadius; y < size.height; y += gap) {
      for (double x = dotRadius; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotsPainter old) =>
      old.color != color || old.gap != gap || old.dotRadius != dotRadius;
}
