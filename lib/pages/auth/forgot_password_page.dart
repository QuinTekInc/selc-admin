
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/pages/auth/auth_pages_background.dart';


class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPagesBackground(
      body: Card(
        elevation: 12,
      
        child: Container(
          width: 450,
          padding: EdgeInsets.all(16),
      
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
        
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
        
            children: [
      
              Container(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 110,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Row(  
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios, size: 30, color: Colors.green.shade400,),
                        Expanded(child: CustomText('Back', textColor: Colors.green.shade300,))
                      ],
                    ),
                  ),
                ),
              ),
      
              const SizedBox(
                height: 12,
              ),
      
              CircleAvatar(
                backgroundColor: Colors.green.shade400,
                radius: 50,
                child: Icon(
                  CupertinoIcons.arrow_clockwise,
                  size: 50,
                  color: Colors.white,
                ),
              ),
        
              SizedBox(height: 8,),
        
              HeaderText('Recover Password'),
        
              const SizedBox(height: 24,),
      
              CustomText('To recover your account, you must provide the email that is associated to your user account.'),
      
              const SizedBox(height: 12,),
        
              CustomTextField(
                controller: TextEditingController(),
                hintText: 'Email',
                useLabel: true,
                leadingIcon: CupertinoIcons.envelope,
              ),
        
              const SizedBox(height: 24,),
      
      
              CustomButton.withText(
                'Continue',
                onPressed: () => handleContinue(context),
                width: double.infinity,
              ),
        
            ]
          )
        ),
      )
    );
  
  }



  void handleContinue(BuildContext context){

    Navigator.push( 
      context,
      MaterialPageRoute(
        builder: (_) => const ConfirmationCodeEntryPage()
      )
    );

  }
}







class ConfirmationCodeEntryPage extends StatelessWidget {
  const ConfirmationCodeEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPagesBackground(
      body:  Card(
        elevation: 12,

        child: Container(
          width: 470,
          padding: EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
        
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
        
            children: [

              Container(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 110,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Row(  
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios, size: 30, color: Colors.green.shade400,),
                        Expanded(child: CustomText('Back', textColor: Colors.green.shade300,))
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              CircleAvatar(
                backgroundColor: Colors.green.shade400,
                radius: 50,
                child: Icon(
                  CupertinoIcons.lock,
                  size: 50,
                  color: Colors.white,
                ),
              ),
        
              SizedBox(height: 8,),
        
              HeaderText('Verification Code'),
        
              const SizedBox(height: 24,),

              CustomText('Enter the six digit code that was sent to your email.'),

              const SizedBox(height: 12,),
        
              OtpTextField(controller: OtpTextEditingController()),

              const SizedBox(height: 8,),

              TextButton(
                onPressed: () => handleResendCode(context), 
                child: CustomText(
                  'Resend Code',
                  textColor: Colors.green.shade500,
                )
              ),
        
              const SizedBox(height: 24,),


              CustomButton.withText(
                'Continue',
                onPressed: () => handleContinue(context),
                width: double.infinity,
              ),
        
            ]
          )
        ),
      )
  
    );
  
  }


  void handleResendCode(BuildContext context){

  }

  void handleContinue(BuildContext context){
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (_) => NewPasswordPage()
      )
    );
  }
}









class NewPasswordPage extends StatelessWidget {

  const NewPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPagesBackground(
      body: Card(
        elevation: 12,
      
        child: Container(
          width: 450,
          padding: EdgeInsets.all(16),
      
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
        
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
        
            children: [
      
              Container(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 110,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Row(  
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios, size: 30, color: Colors.green.shade400,),
                        Expanded(child: CustomText('Back', textColor: Colors.green.shade300,))
                      ],
                    ),
                  ),
                ),
              ),
      
              const SizedBox(
                height: 12,
              ),
      
              CircleAvatar(
                backgroundColor: Colors.green.shade400,
                radius: 50,
                child: Icon(
                  CupertinoIcons.lock,
                  size: 50,
                  color: Colors.white,
                ),
              ),
        
              SizedBox(height: 8,),
        
              HeaderText('Reset Password'),
        
              const SizedBox(height: 24,),
      
              CustomText('Reset your password by entering a new one. ' 
              'For security, it is strongly advised to use strong password, at least 8 characters long'),
      
              const SizedBox(height: 12,),
        
              CustomPasswordField(
                controller: TextEditingController(),
                hintText: 'New Password',
                useLabel: true,
              ),
        
              const SizedBox(height: 24,),
      
      
              CustomButton.withText(
                'Continue',
                onPressed: () => handleContinue(context),
                width: double.infinity,
              ),
        
            ]
          )
        ),
      )
    );
  
  }



  void handleContinue(BuildContext context){

  }
}



