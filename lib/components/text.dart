
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/providers/pref_provider.dart';


class NormalText extends StatelessWidget {

  final String textContent;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final Color textColor;
  final TextAlign textAlignment;

  const NormalText(
    this.textContent,
    {
    super.key,
    this.fontSize = 14,
    this.padding,
    this.textColor = Colors.black87,
    this.textAlignment = TextAlign.left
  });

  @override
  Widget build(BuildContext context) {

    Text text = Text(
      textContent,
      textAlign: textAlignment,
      style: TextStyle(  
        fontSize: fontSize,
        color: textColor,
      ),
    );

    return Padding(  
      padding: (padding == null) ? const EdgeInsets.symmetric(horizontal: 8) : padding!,
      child: text,
    );
  }
}



class HeaderText extends StatelessWidget {

  final String textContent;
  final Color? textColor;
  final TextAlign textAlignment;
  final double fontSize;
  final FontWeight fontWeight;

  const HeaderText(this.textContent,{
    super.key,
    this.textColor = Colors.green,
    this.textAlignment = TextAlign.left,
    this.fontSize = 18,
    this.fontWeight = FontWeight.bold
  });

  factory HeaderText.appBar(String textContent){
    return HeaderText(
      textContent,
      textColor: Colors.white,
      fontSize: 17,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      textContent,
      textAlign: textAlignment,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: 'Poppins'
      )
    );
  }
}



class CustomText extends StatelessWidget {

  final String text;
  final Color textColor;
  final double fontSize;
  final EdgeInsets padding;
  final TextAlign textAlignment;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final int? maxLines;
  final bool? softwrap;
  final TextOverflow? overflow;

  const CustomText(this.text, {
    super.key,
    this.textColor = Colors.black87,
    this.fontSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.textAlignment = TextAlign.left,
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
    this.maxLines,
    this.softwrap,
    this.overflow = TextOverflow.fade
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(  
        text,
        maxLines: maxLines, 
        softWrap: softwrap, 
        textAlign: textAlignment,
        overflow: overflow,
        style: TextStyle(  
          color: textColor,
          fontSize: fontSize + Provider.of<PreferencesProvider>(context).preferences.fontScale,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          fontFamily: "Poppins"
        )
      ),
    );
  }
}






//todo: custom textfield
class CustomTextField extends StatelessWidget {

  final TextEditingController controller;
  final String? hintText;
  final IconData? leadingIcon;
  final Function(String)? onChanged;
  final TextInputType keyboardType;
  final Widget? suffix;
  final int maxLines;
  final bool obscureText;
  final bool useLabel;
  final Color? fillColor;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlignment;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.leadingIcon,
    this.onChanged,
    this.maxLines = 1,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.useLabel = false,
    this.enabled = true,
    this.fillColor,
    this.inputFormatters,
    this.textAlignment = TextAlign.left
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),

      child: TextField(  
        controller: controller,
        onChanged: onChanged,

        maxLines: maxLines,
        obscureText: obscureText,
        textAlign: textAlignment,

        style: TextStyle(
          fontFamily: "Poppins"
        ),


        cursorColor: Colors.black45,

        decoration: InputDecoration(

          contentPadding: EdgeInsets.all(8),

          border: OutlineInputBorder(  
            borderSide: const BorderSide(
              width: 1.5,
              color: Colors.black26
            ),
            borderRadius: BorderRadius.circular(12),
          ),


          enabled: enabled,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              width: 1.5,
              color: Colors.black26
            )
          ),

          
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none
          ),

          focusedBorder: OutlineInputBorder(  
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 1.5,
              color: Colors.green
            )
          ),

          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w500,
            color: Colors.black38
          ),

          filled: true,
          fillColor: fillColor ?? Colors.grey.shade200,

          prefixIcon: leadingIcon == null ? null : Icon(leadingIcon),
          suffix: suffix,
          
          label: (!useLabel || hintText == null) ? null : CustomText(hintText!, fontSize: 15, textColor: Colors.black38,)
        ),

        inputFormatters: inputFormatters,
      ),
    );
  }
}

//todo: custom password field

class CustomPasswordField extends StatefulWidget {

  final TextEditingController controller;
  final String? hintText;
  final bool useLabel;
  final void Function(String)? onChanged;

  const CustomPasswordField({
    super.key, 
    required this.controller,
    this.hintText,
    this.useLabel = true,
    this.onChanged
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {

  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      hintText: widget.hintText,
      obscureText: obscureText,
      leadingIcon: CupertinoIcons.lock,
      useLabel: widget.useLabel,
      suffix: buildTrailingIconButton(),
      onChanged: widget.onChanged,
    );
  }

  Widget buildTrailingIconButton() => GestureDetector(
    onTap: (){
      setState(() {
        obscureText = !obscureText;
      });
    }, 
    child: Icon(obscureText ? CupertinoIcons.eye : CupertinoIcons.eye, color: Colors.green, size: 20,)
  );
}






//todo: a six digit code otp text field.
class OtpTextField extends StatefulWidget {

  final OtpTextEditingController controller;

  const OtpTextField({super.key, required this.controller});

  @override
  State<OtpTextField> createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {

  final List<TextEditingController> textControllers = List.generate(6, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
      
        children: List<Widget>.generate(6, (index) {

          return Expanded(
            
            child: CustomTextField(
              controller: textControllers[index],
              textAlignment: TextAlign.center,
              keyboardType: TextInputType.number,

              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly
              ],

              onChanged: (newValue){
                    
                if(textControllers[index].text.length == 1 && index != 5) FocusScope.of(context).nextFocus();

                String otpText = '';

                //todo: collect the text from every text field in the Otp Text field controllers. 
                for(TextEditingController textController in textControllers){
                 otpText += textController.text;
                }


                widget.controller.text = otpText;

              },
            )
          );
        }),
      ),
    );
  }
}

class OtpTextEditingController{

  String text;

  OtpTextEditingController({this.text=''});

  void clear(){
    text = '';
  }

}





class CustomDropdownButton<T> extends StatefulWidget {

  final List<T> items;
  final DropdownController controller;
  final Function(T? newValue)? onChanged;
  final String? hint;
  final IconData? icon;
  final Color? backgroundColor;

  const CustomDropdownButton({
    super.key,
    required this.controller, 
    this.hint,
    this.icon,
    required this.items, 
    required this.onChanged,
    this.backgroundColor
  });

  @override
  State<CustomDropdownButton> createState() => _CustomDropdownButtonState<T>();
}

class _CustomDropdownButtonState<T> extends State<CustomDropdownButton<T>> {

  @override
  Widget build(BuildContext context) {
    return Container(

      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(horizontal: 8),

      decoration: BoxDecoration(

        color: widget.backgroundColor ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: Colors.black26,
          width: 1.5
        )
      ),

      child: DropdownButton<T>(

        value: widget.controller.value,
        icon: Icon(
          widget.icon ?? Icons.arrow_drop_down, 
          color: Colors.green.shade400, 
          size: widget.icon == null ? 28 : null,
        ),
        isExpanded: true,
        isDense: true,

        underline: SizedBox(),

        hint: widget.hint != null ? CustomText(
          widget.hint!,
          fontWeight: FontWeight.w600,
          textColor: Colors.black38,
        ) : null,

        items: List<DropdownMenuItem<T>>.generate(  
          widget.items.length,
          (index) => DropdownMenuItem<T>(
            value: widget.items[index],
            child: CustomText(
              widget.items[index].toString()
            ),
          )
        ), 


        borderRadius: BorderRadius.circular(12),
        dropdownColor: Colors.grey.shade100,
        focusColor: Colors.green.shade100,

        onChanged: (newValue) {

          setState(() => widget.controller.value = newValue);
          

          if(widget.onChanged != null){
            widget.onChanged!.call(newValue);
          }
          
        }
      ),
    );
  }
}


class DropdownController<T>{

  T? value;


  DropdownController({this.value});

  void reset() => value = null;

}





class CollectionPlaceholder extends StatelessWidget {

  final String? title;
  final String detail;

  const CollectionPlaceholder({super.key, this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [

          if(title != null)CustomText(
            title!,
            fontWeight: FontWeight.bold,
            textAlignment: TextAlign.center,
          ),

          CustomText(  
            detail,
            textAlignment: TextAlign.center,
          ),
        ],
      ),
    
    );
  }
}

