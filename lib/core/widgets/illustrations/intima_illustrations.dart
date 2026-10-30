import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

/// Type d'illustration vectorielle INTIMA.
enum IntimaIllustrationType {
  heart,
  cycle,
  journal,
  shield,
  partners,
  emptyBox,
}

/// Widget racine pour afficher une illustration vectorielle animée INTIMA.
class IntimaAnimatedIllustration extends StatefulWidget {
  const IntimaAnimatedIllustration({
    super.key,
    required this.type,
    this.size = 140,
    this.primaryColor,
    this.secondaryColor,
  });

  final IntimaIllustrationType type;
  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  @override
  State<IntimaAnimatedIllustration> createState() =>
      _IntimaAnimatedIllustrationState();
}

class _IntimaAnimatedIllustrationState extends State<IntimaAnimatedIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathAnim;
  late Animation<double> _floatAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _breathAnim = Tween<double>(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _floatAnim = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _rotateAnim = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primary = widget.primaryColor ?? AppColors.primary;
    final secondary = widget.secondaryColor ??
        (widget.type == IntimaIllustrationType.cycle
            ? AppColors.calendarPeriod
            : widget.type == IntimaIllustrationType.shield
                ? AppColors.sage
                : widget.type == IntimaIllustrationType.journal
                    ? const Color(0xFF7E57C2)
                    : AppColors.accent);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Halo lumineux arrière pulsant
              Transform.scale(
                scale: _breathAnim.value * 1.1,
                child: Container(
                  width: widget.size * 0.75,
                  height: widget.size * 0.75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primary.withValues(alpha: isDark ? 0.25 : 0.18),
                        secondary.withValues(alpha: isDark ? 0.12 : 0.06),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.65, 1.0],
                    ),
                  ),
                ),
              ),

              // 2. Tracé vectoriel principal flottant
              Transform.translate(
                offset: Offset(0, _floatAnim.value),
                child: Transform.rotate(
                  angle: _rotateAnim.value,
                  child: CustomPaint(
                    size: Size(widget.size * 0.82, widget.size * 0.82),
                    painter: _getPainter(
                      type: widget.type,
                      primaryColor: primary,
                      secondaryColor: secondary,
                      progress: _controller.value,
                      isDark: isDark,
                    ),
                  ),
                ),
              ),

              // 3. Étincelles et particules décoratives
              ..._buildFloatingParticles(primary, secondary, widget.size),
            ],
          ),
        );
      },
    );
  }

  CustomPainter _getPainter({
    required IntimaIllustrationType type,
    required Color primaryColor,
    required Color secondaryColor,
    required double progress,
    required bool isDark,
  }) {
    switch (type) {
      case IntimaIllustrationType.heart:
        return _HeartVectorPainter(
          primaryColor: primaryColor,
          accentColor: secondaryColor,
          progress: progress,
          isDark: isDark,
        );
      case IntimaIllustrationType.cycle:
        return _CycleFlowerPainter(
          primaryColor: primaryColor,
          accentColor: secondaryColor,
          progress: progress,
          isDark: isDark,
        );
      case IntimaIllustrationType.journal:
        return _JournalVectorPainter(
          primaryColor: primaryColor,
          accentColor: secondaryColor,
          progress: progress,
          isDark: isDark,
        );
      case IntimaIllustrationType.shield:
        return _ShieldVectorPainter(
          primaryColor: primaryColor,
          accentColor: secondaryColor,
          progress: progress,
          isDark: isDark,
        );
      case IntimaIllustrationType.partners:
        return _PartnersVectorPainter(
          primaryColor: primaryColor,
          accentColor: secondaryColor,
          progress: progress,
          isDark: isDark,
        );
      case IntimaIllustrationType.emptyBox:
        return _EmptyBoxVectorPainter(
          primaryColor: primaryColor,
          accentColor: secondaryColor,
          progress: progress,
          isDark: isDark,
        );
    }
  }

  List<Widget> _buildFloatingParticles(
      Color primary, Color secondary, double size) {
    final t = _controller.value;
    return [
      Positioned(
        top: size * 0.15 + math.sin(t * math.pi * 2) * 4,
        right: size * 0.18,
        child: _SparkleWidget(
          size: 14,
          color: secondary.withValues(alpha: 0.8),
          rotation: t * math.pi,
        ),
      ),
      Positioned(
        bottom: size * 0.22 - math.cos(t * math.pi * 2) * 5,
        left: size * 0.15,
        child: _SparkleWidget(
          size: 10,
          color: primary.withValues(alpha: 0.65),
          rotation: -t * math.pi * 0.8,
        ),
      ),
      Positioned(
        top: size * 0.28,
        left: size * 0.2,
        child: Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: secondary.withValues(alpha: 0.5 + 0.3 * math.sin(t * math.pi)),
          ),
        ),
      ),
      Positioned(
        bottom: size * 0.25,
        right: size * 0.22,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withValues(alpha: 0.4 + 0.3 * math.cos(t * math.pi)),
          ),
        ),
      ),
    ];
  }
}

/// Petite étoile scintillante vectorielle
class _SparkleWidget extends StatelessWidget {
  const _SparkleWidget({
    required this.size,
    required this.color,
    required this.rotation,
  });

  final double size;
  final Color color;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: CustomPaint(
        size: Size(size, size),
        painter: _StarPainter(color: color),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    path.moveTo(cx, 0);
    path.quadraticBezierTo(cx, cy * 0.65, w, cy);
    path.quadraticBezierTo(cx * 1.35, cy, cx, h);
    path.quadraticBezierTo(cx, cy * 1.35, 0, cy);
    path.quadraticBezierTo(cx * 0.65, cy, cx, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      color != oldDelegate.color;
}

// ─── 1. Peintre Vectoriel Cœur Organique INTIMA ──────────────────────────────

class _HeartVectorPainter extends CustomPainter {
  _HeartVectorPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.progress,
    required this.isDark,
  });

  final Color primaryColor;
  final Color accentColor;
  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dégradé riche
    final gradient = LinearGradient(
      colors: [
        primaryColor,
        accentColor,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final rect = Rect.fromLTWH(0, 0, w, h);
    final mainPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(w * 0.5, h * 0.85);

    // Côté gauche
    path.cubicTo(
      w * 0.12,
      h * 0.62,
      w * 0.05,
      h * 0.35,
      w * 0.24,
      h * 0.18,
    );
    path.cubicTo(
      w * 0.38,
      h * 0.08,
      w * 0.48,
      h * 0.22,
      w * 0.5,
      h * 0.32,
    );

    // Côté droit
    path.cubicTo(
      w * 0.52,
      h * 0.22,
      w * 0.62,
      h * 0.08,
      w * 0.76,
      h * 0.18,
    );
    path.cubicTo(
      w * 0.95,
      h * 0.35,
      w * 0.88,
      h * 0.62,
      w * 0.5,
      h * 0.85,
    );
    path.close();

    // Ombre douce sous le cœur
    canvas.drawShadow(path, primaryColor.withValues(alpha: 0.35), 8, true);
    canvas.drawPath(path, mainPaint);

    // Reflet de lumière soyeux en arc supérieur
    final highlightPath = Path();
    highlightPath.moveTo(w * 0.22, h * 0.24);
    highlightPath.cubicTo(
      w * 0.28,
      h * 0.16,
      w * 0.38,
      h * 0.16,
      w * 0.44,
      h * 0.24,
    );

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.3 : 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _HeartVectorPainter oldDelegate) => true;
}

// ─── 2. Peintre Vectoriel Cycle / Lotus Organique ────────────────────────────

class _CycleFlowerPainter extends CustomPainter {
  _CycleFlowerPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.progress,
    required this.isDark,
  });

  final Color primaryColor;
  final Color accentColor;
  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.52);

    // 1. Cercle d'orbite pointillé fin
    final orbitPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, w * 0.36, orbitPaint);

    // 2. Pétales floraux organiques du cycle
    final petalCount = 6;
    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * math.pi / petalCount) + (progress * 0.15);
      final petalPaint = Paint()
        ..color = (i % 2 == 0 ? primaryColor : accentColor)
            .withValues(alpha: 0.75)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final petalPath = Path();
      petalPath.moveTo(0, 0);
      petalPath.quadraticBezierTo(w * 0.12, -h * 0.2, 0, -h * 0.34);
      petalPath.quadraticBezierTo(-w * 0.12, -h * 0.2, 0, 0);
      petalPath.close();

      canvas.drawPath(petalPath, petalPaint);
      canvas.restore();
    }

    // 3. Goutte centrale de fertilité
    final dropPath = Path();
    dropPath.moveTo(center.dx, center.dy - h * 0.14);
    dropPath.cubicTo(
      center.dx + w * 0.12,
      center.dy,
      center.dx + w * 0.1,
      center.dy + h * 0.12,
      center.dx,
      center.dy + h * 0.12,
    );
    dropPath.cubicTo(
      center.dx - w * 0.1,
      center.dy + h * 0.12,
      center.dx - w * 0.12,
      center.dy,
      center.dx,
      center.dy - h * 0.14,
    );
    dropPath.close();

    final dropPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, primaryColor],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.15));

    canvas.drawShadow(dropPath, primaryColor.withValues(alpha: 0.4), 6, true);
    canvas.drawPath(dropPath, dropPaint);
  }

  @override
  bool shouldRepaint(covariant _CycleFlowerPainter oldDelegate) => true;
}

// ─── 3. Peintre Vectoriel Journal Intime ─────────────────────────────────────

class _JournalVectorPainter extends CustomPainter {
  _JournalVectorPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.progress,
    required this.isDark,
  });

  final Color primaryColor;
  final Color accentColor;
  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Carnet ouvert / Feuillets
    final bookRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.46, h * 0.52),
        width: w * 0.62,
        height: h * 0.72,
      ),
      const Radius.circular(12),
    );

    final coverPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF7E57C2), const Color(0xFF5E35B1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bookRect.outerRect);

    canvas.drawRRect(bookRect, coverPaint);

    // Feuillets internes clairs
    final pagesRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.49, h * 0.52),
        width: w * 0.52,
        height: h * 0.64,
      ),
      const Radius.circular(8),
    );

    final pagesPaint = Paint()
      ..color = isDark ? const Color(0xFF2C2433) : const Color(0xFFFAF7FC);
    canvas.drawRRect(pagesRect, pagesPaint);

    // Lignes d'écriture douces
    final linePaint = Paint()
      ..color = const Color(0xFF7E57C2).withValues(alpha: 0.3)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final y = h * 0.36 + (i * h * 0.08);
      canvas.drawLine(
        Offset(w * 0.3, y),
        Offset(w * (i == 3 ? 0.52 : 0.66), y),
        linePaint,
      );
    }

    // 2. Plume dorée ou ruban marque-page
    final ribbonPath = Path();
    ribbonPath.moveTo(w * 0.68, h * 0.2);
    ribbonPath.lineTo(w * 0.82, h * 0.35);
    ribbonPath.lineTo(w * 0.74, h * 0.42);
    ribbonPath.lineTo(w * 0.60, h * 0.27);
    ribbonPath.close();

    final penPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.accent, const Color(0xFFFFA726)],
      ).createShader(Rect.fromLTWH(w * 0.5, h * 0.2, w * 0.35, h * 0.3));

    canvas.drawPath(ribbonPath, penPaint);
  }

  @override
  bool shouldRepaint(covariant _JournalVectorPainter oldDelegate) => true;
}

// ─── 4. Peintre Vectoriel Bouclier Santé Organique ───────────────────────────

class _ShieldVectorPainter extends CustomPainter {
  _ShieldVectorPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.progress,
    required this.isDark,
  });

  final Color primaryColor;
  final Color accentColor;
  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.48);

    // Bouclier doux
    final path = Path();
    path.moveTo(w * 0.5, h * 0.16);
    path.cubicTo(w * 0.75, h * 0.16, w * 0.84, h * 0.25, w * 0.84, h * 0.46);
    path.cubicTo(w * 0.84, h * 0.68, w * 0.64, h * 0.82, w * 0.5, h * 0.88);
    path.cubicTo(w * 0.36, h * 0.82, w * 0.16, h * 0.68, w * 0.16, h * 0.46);
    path.cubicTo(w * 0.16, h * 0.25, w * 0.25, h * 0.16, w * 0.5, h * 0.16);
    path.close();

    final shieldGradient = LinearGradient(
      colors: [AppColors.sage, const Color(0xFF2D5A46)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final shieldPaint = Paint()
      ..shader = shieldGradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawShadow(path, AppColors.sage.withValues(alpha: 0.35), 8, true);
    canvas.drawPath(path, shieldPaint);

    // Symbole de protection / Croix douce arrondie ou cœur de santé
    final crossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx, center.dy - h * 0.1),
      Offset(center.dx, center.dy + h * 0.1),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx - w * 0.1, center.dy),
      Offset(center.dx + w * 0.1, center.dy),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ShieldVectorPainter oldDelegate) => true;
}

// ─── 5. Peintre Vectoriel Connexion Partenaires ──────────────────────────────

class _PartnersVectorPainter extends CustomPainter {
  _PartnersVectorPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.progress,
    required this.isDark,
  });

  final Color primaryColor;
  final Color accentColor;
  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Premier orbe (Partenaire 1)
    final p1Paint = Paint()
      ..shader = RadialGradient(
        colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.38, h * 0.48), radius: w * 0.24));

    // Deuxième orbe (Partenaire 2)
    final p2Paint = Paint()
      ..shader = RadialGradient(
        colors: [accentColor, accentColor.withValues(alpha: 0.7)],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.62, h * 0.48), radius: w * 0.24));

    canvas.drawCircle(Offset(w * 0.38, h * 0.48), w * 0.22, p1Paint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.48), w * 0.22, p2Paint);

    // Cœur de connexion à l'intersection
    final heartPath = Path();
    final cx = w * 0.5;
    final cy = h * 0.48;

    heartPath.moveTo(cx, cy + h * 0.1);
    heartPath.cubicTo(cx - w * 0.08, cy + h * 0.04, cx - w * 0.09, cy - h * 0.04, cx - w * 0.04, cy - h * 0.06);
    heartPath.cubicTo(cx - w * 0.01, cy - h * 0.07, cx, cy - h * 0.03, cx, cy - h * 0.01);
    heartPath.cubicTo(cx, cy - h * 0.03, cx + w * 0.01, cy - h * 0.07, cx + w * 0.04, cy - h * 0.06);
    heartPath.cubicTo(cx + w * 0.09, cy - h * 0.04, cx + w * 0.08, cy + h * 0.04, cx, cy + h * 0.1);
    heartPath.close();

    final heartPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawPath(heartPath, heartPaint);
  }

  @override
  bool shouldRepaint(covariant _PartnersVectorPainter oldDelegate) => true;
}

// ─── 6. Peintre Vectoriel État Neutre / Découverte ───────────────────────────

class _EmptyBoxVectorPainter extends CustomPainter {
  _EmptyBoxVectorPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.progress,
    required this.isDark,
  });

  final Color primaryColor;
  final Color accentColor;
  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final boxPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.52), width: w * 0.54, height: h * 0.54),
      const Radius.circular(16),
    );

    canvas.drawRRect(rect, boxPaint);

    final innerCircle = Paint()
      ..color = accentColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.5, h * 0.52), 6, innerCircle);
  }

  @override
  bool shouldRepaint(covariant _EmptyBoxVectorPainter oldDelegate) => true;
}

// ─── Badge Héroïque d'Accueil INTIMA ────────────────────────────────────────

class AnimatedIntimaHeroBadge extends StatefulWidget {
  const AnimatedIntimaHeroBadge({super.key, this.size = 54});

  final double size;

  @override
  State<AnimatedIntimaHeroBadge> createState() =>
      _AnimatedIntimaHeroBadgeState();
}

class _AnimatedIntimaHeroBadgeState extends State<AnimatedIntimaHeroBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final scale = 1.0 + 0.05 * math.sin(_anim.value * math.pi * 2);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        );
      },
    );
  }
}

