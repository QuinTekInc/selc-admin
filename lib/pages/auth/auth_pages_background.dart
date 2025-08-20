

import 'package:flutter/material.dart';

class AuthPagesBackground extends StatelessWidget {
  final Widget body;

  const AuthPagesBackground({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: Container(  
        margin: EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/imgs/UENR-Logo.png'),
            opacity: 0.4
          )
        ),


        child: Opacity(opacity: 0.9, child: body),
      ),
    );
  }
}