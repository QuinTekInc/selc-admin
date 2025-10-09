
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/providers/page_provider.dart';
import 'package:selc_admin/providers/pref_provider.dart';

class CustomButton extends StatelessWidget {

  final Widget? child;
  final EdgeInsets padding;
  final Function() onPressed;
  final Color? backgroundColor;
  final double height;
  final double? width;
  final bool disable;

  const CustomButton({
    super.key,
    required this.onPressed,
    this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.backgroundColor,
    this.height = 50,
    this.width,
    this.disable = false
  });

  //button with only text in it.
  factory CustomButton.withText(String text, {
    required Function() onPressed, 
    double? width, 
    bool disable = false,
    Color? backgroundColor
  }){

    return CustomButton(
      onPressed: onPressed,
      width: width,
      disable: disable,
      backgroundColor: backgroundColor,
      child: CustomText(text, fontSize: 16, textColor: Colors.white, softwrap: true, overflow: TextOverflow.ellipsis,),
    );
  }


  //button with text and an Icon
  factory CustomButton.withIcon(String text, {
    required Function() onPressed, 
    required IconData icon, 
    Color iconColor = Colors.white,
    Color? backgroundColor,
    bool forceIconLeading = false,
    double? width,
    bool disable = false
  }){


    Icon iconWidget = Icon(icon, color: iconColor,);

    CustomText textWidget = CustomText(
      text, 
      fontSize: 16, 
      textColor: Colors.white, 
      padding: EdgeInsets.zero,
      overflow: TextOverflow.ellipsis,
      softwrap: true,
    );

    return CustomButton(
      onPressed: onPressed,
      width: 70, 
      disable: disable,
      backgroundColor: backgroundColor,
      child: SizedBox(
        width: width,
        child: Row( 
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: [

            if(forceIconLeading) iconWidget else textWidget,


            if(forceIconLeading) textWidget else iconWidget
            
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Padding(
      padding: padding,

      child: IgnorePointer(
        ignoring: disable,

        child: MaterialButton(
          onPressed: onPressed,
          height: height,
          minWidth: width,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          ),
          color: backgroundColor ?? Colors.green.shade400,
          child: child,
        ),

      ),
    );
  }
}



//todo: custom checkBoxes.
class CustomCheckBox extends StatelessWidget {

  final bool value;
  final String text;
  final Function(bool? newValue)? onChanged;
  final MainAxisAlignment alignment;

  const CustomCheckBox({
    super.key,
    required this.value,
    required this.text,
    this.onChanged,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(  
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: alignment,
      children: [
        Checkbox(
          value: value, 
          onChanged: onChanged,
          activeColor: Colors.green,
        ),
        CustomText(text, fontSize: 14, fontWeight: FontWeight.w500)
      ],
    );
  }
}





class NavigationTextButtons extends StatefulWidget {

  const NavigationTextButtons({super.key});

  @override
  State<NavigationTextButtons> createState() => _NavigationTextButtonsState();
}

class _NavigationTextButtonsState extends State<NavigationTextButtons> {

  Color? hoverColor;
  List<bool> hoverList = [];
  
  @override
  void initState() {

    hoverColor = Colors.transparent;
    hoverList = List<bool>.generate(
      Provider.of<PageProvider>(context, listen: false).navigatorStack.length, 
      (index) => false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    PageProvider pageProvider = Provider.of<PageProvider>(context);

    return Row( 
      mainAxisAlignment: MainAxisAlignment.start, 
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(
        pageProvider.navigatorStack.length,
        (index){

          bool isLast = index == pageProvider.navigatorStack.length-1;
        
          String bullet = index == 0 ? '' : '⮞';
    
          Widget btnText = MouseRegion(

            onEnter: (pointerEvent) {

              if(isLast) return;

              setState(() {
                hoverList[index] = true;
                hoverColor = Theme.of(context).brightness == Brightness.dark ? Colors.green.shade300 : Colors.green.shade50;
              });
            },


            onExit: (pointerEvent) {

              if(isLast) return;

              setState(() {
                hoverList[index] = false;
                hoverColor = Colors.transparent;
              });
            },

            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(3),
            
              decoration: BoxDecoration(
                color: isLast || !hoverList[index] ? Colors.transparent :  hoverColor,
                borderRadius: BorderRadius.circular(12)
              ),
            
              child: CustomText(
                '$bullet ${pageProvider.pageNames[index]}',
                fontSize: 12,
                textColor: isLast ? Colors.green.shade300 : null,
                fontWeight: FontWeight.w600,
                textAlignment: TextAlign.left,
              ),
            ),
          );
    
    
          if(index == pageProvider.navigatorStack.length -1) return btnText;
    
    
          return GestureDetector(
            onTap: () => pageProvider.popUntil(() => pageProvider.navigatorStack.length-1 == index), 
            child: btnText
          );
    
        }
      ),
    );
  }
}






//todo: build the foward arrow button for 
class DashSeeMoreButton extends StatefulWidget {
  
  final void Function() onPressed;

  const DashSeeMoreButton({super.key, required this.onPressed});

  @override
  State<DashSeeMoreButton> createState() => _DashSeeMoreButtonState();
}

class _DashSeeMoreButtonState extends State<DashSeeMoreButton> {

  Color hoverColor = Colors.green.shade400;

  Color borderColor = Colors.transparent;
  Color iconColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return  MouseRegion(
      onHover: (mouseEvent) => setState((){
        borderColor = hoverColor;
        iconColor = hoverColor;
      }),
      onExit: (mouseEvent) => setState((){
        borderColor = Colors.transparent;
        iconColor = Colors.white;
      }),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(  
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
            color: PreferencesProvider.getColor(context, 'alt-primary-color')
          ),
          child: Icon(  
            Icons.arrow_forward_ios,
            color: iconColor,
            size: 45,
          )
        ),
      ),
    );
  }
}

