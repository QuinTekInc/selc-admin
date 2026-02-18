
import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {

  final List<String> tabLabels;
  final bool disable;
  final void Function(int) onChanged;
  final bool isScrollable;

  const CustomTabBar({
    super.key,
    required this.tabLabels,
    this.disable = false,
    this.isScrollable = false,
    required this.onChanged
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
      height: 50,
      width: double.infinity, //MediaQuery.of(context).size.width * 0.4,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400)
      ),

      child: IgnorePointer(
        ignoring: widget.disable,
        child: TabBar(
          indicatorColor: Colors.green.shade200,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicatorPadding: EdgeInsets.zero,

          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.green.shade400,
          ),

          padding: const EdgeInsets.all(4),
          labelPadding: const EdgeInsets.all(8),
          indicatorAnimation: TabIndicatorAnimation.elastic,
          labelColor: Colors.white,

          labelStyle: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600
          ),

          unselectedLabelStyle: TextStyle(
              fontFamily: 'Poppins'
          ),

          tabs: List<Tab>.generate(widget.tabLabels.length, (index) => Tab(text: widget.tabLabels[index])),

          onTap: widget.onChanged,
        ),
      ),
    );
  }
}
