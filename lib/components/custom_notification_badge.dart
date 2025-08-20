
import 'package:flutter/material.dart';


class NotificationBadge extends StatelessWidget {


  final bool hasNotification;
  final Widget child;

  const NotificationBadge({super.key, this.hasNotification=false, required this.child});



  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,

      constraints: BoxConstraints(
        minHeight: 40,
        minWidth: 40
      ),

      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
      
          Positioned(
            top: 0,
            right: 0,
      
            child: Container(
              height: 12,
              width: 12,
      
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.shade400
              ),
            ),
          )
        ],
      ),
    );
  }
}