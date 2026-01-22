
import 'package:flutter/material.dart';
import 'package:selc_admin/components/text.dart';

void showCustomAlertDialog(BuildContext context,{
  AlertType alertType = AlertType.info,
  required String title, 
  required String contentText,
  List<TextButton>? controls,
  bool addDefaultButton = true,
  String? defaultButtonText,
  VoidCallback? onDismiss,
}){



  //TODO: Use this inner function to create default button
  TextButton buildDefaultButton(BuildContext alertContext){
    return TextButton(
      child: CustomText(
        defaultButtonText ?? 'Close', 
        fontSize: 15, 
        textColor: alertType.iconColor, 
        fontWeight: FontWeight.w600,
      ),
      onPressed: () {
        Navigator.pop(alertContext);
        if(onDismiss != null){
          onDismiss.call();
        }
      },
    );
  }



  if(controls != null && addDefaultButton){
    controls.add(buildDefaultButton(context));
  }


  showDialog(
    context: context,
    builder: (_) => AlertDialog(

      icon: Icon(
        alertType.iconData,
        color: alertType.iconColor,
        size: 50,
      ),

      title: HeaderText(
        title, 
        fontSize: 18, 
        textAlignment: TextAlign.center,
      ),
      content: SizedBox(
        width: 400,
        child: CustomText(
          contentText,
          fontSize: 14,
          textAlignment: TextAlign.center,
        ),
      ),

      actions: controls ?? [buildDefaultButton(context)],
    )
  );

}




void showNoConnectionAlertDialog(BuildContext context){
  return showCustomAlertDialog(
    context, 
    title: 'Error', 
    contentText: 'Could not connect to the server........Make sure you have an active internet connection and try again',
    alertType: AlertType.warning
  );
}


enum AlertType{

  warning(Icons.warning, Colors.redAccent),
  success(Icons.done_all, Colors.green),
  info(Icons.info, Colors.blue);

  final IconData iconData;
  final Color iconColor;

  const AlertType(this.iconData, this.iconColor);

}



class LoadingDialog extends StatelessWidget {

  final String? message;
  
  const LoadingDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(

      title: HeaderText('Loading', textAlignment: TextAlign.center,),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [

          SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(
              color: Colors.green.shade400,
            )
          ),

          const SizedBox(height: 8,),

          CustomText(message ?? 'Please wait')
        ],
      ),
    );
  }
}


void showToastMessage(BuildContext context, String details){
  ScaffoldMessenger.of(context).showMaterialBanner(
    MaterialBanner(
      backgroundColor: Colors.grey.shade100,
      surfaceTintColor: Colors.grey.shade100,
      leadingPadding: EdgeInsets.zero,
      margin: const EdgeInsets.all(8),
        content: Padding(
          padding: const EdgeInsets.all(3.0),
          child: CustomText(details, fontWeight: FontWeight.w500,),
        ),
        actions: [
          TextButton(
              onPressed: ()=>ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
              child: CustomText('CLOSE', textColor: Colors.green.shade400, fontWeight: FontWeight.w600,)
          )
        ]
    )
  );
}



void showCustomModalBottomSheet({
  required BuildContext context, 
  required Widget child, 
  Alignment alignment=Alignment.bottomRight,
  bool isScrollControlled = false,
  bool isDismissible = true,
  }) => showModalBottomSheet(
  context: context, 
  isScrollControlled: isScrollControlled,
  isDismissible: isDismissible,
  constraints: BoxConstraints(
    minHeight: MediaQuery.of(context).size.height,
    maxHeight: MediaQuery.of(context).size.height
  ),
  backgroundColor: Colors.transparent,
  builder: (_) => Align(  
    alignment: alignment,
    child: child,
  )
);
