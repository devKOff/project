import 'package:flutter/material.dart';
import '../models/member.dart';

class MemberAvatar extends StatelessWidget {
  final Member member;
  final double radius;

  const MemberAvatar({super.key, required this.member, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: member.color,
      child: Text(
        member.initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.75,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}