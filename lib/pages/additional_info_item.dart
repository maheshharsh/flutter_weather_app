import 'package:flutter/material.dart';

class AdditionalInfoItem extends StatelessWidget {
  final IconData icon;
  final String atmosphere;
  final String text;
  const AdditionalInfoItem({required this.icon, required this.atmosphere, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
        ),
        SizedBox(height: 8,),
        Text(atmosphere, style: TextStyle(fontSize: 16),),
        SizedBox(height: 8,),
        Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
      ],
    );
  }
}
