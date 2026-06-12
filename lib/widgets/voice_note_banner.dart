import 'package:flutter/material.dart';

class VoiceNoteBanner extends StatefulWidget {
  const VoiceNoteBanner({super.key});

  @override
  State<VoiceNoteBanner> createState() => _VoiceNoteBannerState();
}

class _VoiceNoteBannerState extends State<VoiceNoteBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Container(
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: Color.lerp(const Color(0xFF1D9E75), Colors.white24, _pulseCtrl.value),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Arjun started a voice note · 0:12',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
          Icon(Icons.play_arrow_rounded, color: const Color(0xFF7C6FF7), size: 20),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _visible = false),
            child: const Icon(Icons.close, color: Colors.white38, size: 16),
          ),
        ],
      ),
    );
  }
}