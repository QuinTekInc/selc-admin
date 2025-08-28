

import 'package:flutter/material.dart';
import 'package:selc_admin/providers/pref_provider.dart';

class AuthPagesBackground extends StatelessWidget {
  final Widget body;

  const AuthPagesBackground({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PreferencesProvider.getColor(context, 'primary-color'),

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