
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/course_profile_page.dart';
import 'package:selc_admin/providers/page_provider.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';

//todo: the question category cell.
class CategoryCell extends StatelessWidget {

  final Category category;
  final Function() onEditPressed;
  final Function() onDeletePressed;

  const CategoryCell({super.key, required this.category, required this.onEditPressed, required this.onDeletePressed});

  @override
  Widget build(BuildContext context) {
    return Container(

      padding: EdgeInsets.all(8),

      decoration: BoxDecoration(
        //Colors.grey.shade200
        color: PreferencesProvider.getColor(context, 'primary-color'),
        borderRadius: BorderRadius.circular(8)
      ),

      child: ListTile(
        leading: Icon(CupertinoIcons.cube, size: 30, color: Colors.green.shade400,),
        title: CustomText(
          category.categoryName,
          fontSize: 16,
        ),


        trailing: !(Provider.of<SelcProvider>(context).user.isSuperuser) ? null : PopupMenuButton<String>(
          icon: Icon(CupertinoIcons.ellipsis_vertical),
          onSelected: (value){

            switch(value){
              case 'edit':
                //todo: handle the categories here.
                onEditPressed();
                return;

              case 'delete':
                //todo: call the delete function
                onDeletePressed();
                return;
            }

          },

          itemBuilder: (_) => [

            PopupMenuItem(
              value: 'edit',
              child: Row(  
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.square_pencil,),
                  const SizedBox(width: 8,),
                  CustomText('Edit')
                ],
              ),
            ),

            PopupMenuItem(
              value: 'delete',
              child: Row(  
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.delete, color: Colors.red.shade400,),
                  const SizedBox(width: 8,),
                  CustomText('Delete', textColor: Colors.red.shade400,)
                ],
              ),
            ),

          ],
          
        ),
      ),
    );
  }
}







//todo: Question list cell
class QuestionCell extends StatelessWidget {

  final Question question;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const QuestionCell({
    super.key, 
    required this.question, 
    required this.onEditPressed, 
    required this.onDeletePressed
  });

  @override
  Widget build(BuildContext context) {

    return Container(
                                                  
      margin: EdgeInsets.only(bottom: 8),
                      
      decoration: BoxDecoration(  
        color: PreferencesProvider.getColor(context, 'primary-color'),
        borderRadius: BorderRadius.circular(8)
      ),
                      
      child: ListTile(
      
        leading: Icon(CupertinoIcons.chat_bubble_2, size: 30, color: Colors.green.shade400,),
      
        title: CustomText(
          question.question,
          maxLines: 2,
          softwrap: true,
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      
      
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [

            CustomText(
              question.category.toString(),
              fontWeight: FontWeight.w600,
              textColor: Colors.green.shade400,
            ),

            const SizedBox(width: 16,),


            Container(  
              padding: const EdgeInsets.all(3),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Theme.of(context).brightness == Brightness.dark ? Colors.green.shade400 : Colors.green.shade100
              ),

              child: CustomText(  
                question.answerType!.typeString
              ),
            ),

          ],
        ),


        trailing: !(Provider.of<SelcProvider>(context).user.isSuperuser) ? null : Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            IconButton(
              onPressed: onEditPressed, 
              icon: Icon(Icons.edit, color: Colors.blue.shade300,),
              tooltip: 'Edit',
            ),

            const SizedBox(width: 12,),

            IconButton(
              onPressed: onDeletePressed, 
              icon: Icon(CupertinoIcons.delete, color: Colors.red.shade300,),
              tooltip: 'Delete',
            )
          ],
        ),
      
      ),
    );
  }
}



//todo: course cell.
class CourseCell extends StatefulWidget {

  final Course course;

  const CourseCell({super.key, required this.course});

  @override
  State<CourseCell> createState() => _CourseCellState();
}

class _CourseCellState extends State<CourseCell> {
  final Color transparentColor = Colors.transparent;
  final Color hoverColor = Colors.green.shade400;

  Color borderColor = Colors.transparent;
  double elevation = 3;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(

      onHover: (_) => setState(() {
        borderColor = hoverColor;
        elevation = 10;
      }),

      onExit: (_) => setState(() {
        borderColor = transparentColor;
        elevation = 10;
      }),

      child: GestureDetector(
        onTap: () => Provider.of<PageProvider>(context, listen: false).pushPage(CourseProfilePage(course: widget.course), 'Course Profile'),
      
        child: Card(

          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 1.5)
          ),
        
          child: Container(
            width: 240,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12)
            ),
          
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
          
              children: [
          
                Container(
                  height: 150,
                  alignment: Alignment.center,
                                
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12))
                  ),
                                
                  child: Icon(CupertinoIcons.book, color: Colors.white, size: 45,),
                ),
        
                const SizedBox(height: 4,),
          
                CustomText(
                  widget.course.courseCode,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
          
                CustomText(
                  widget.course.title,
                  softwrap: true,
                  maxLines: 2,
                )
          
              ],
          
            ),
          ),
        ),
      ),
    );
              
  }
}







class DetailContainer extends StatelessWidget {

  final String title;
  final String detail;

  const DetailContainer({super.key, required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),

      decoration: BoxDecoration(
        //Colors.grey.shade100
        color: PreferencesProvider.getColor(context, 'primary-color'),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black38)
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
      
        children: [
      
          CustomText(
            title,
            fontWeight: FontWeight.w600
          ),
      
          const SizedBox(height: 3),
      
          CustomText(
            detail,
            softwrap: true,
          )
        ],
      ),
    );
  }
}







class ClickableMenuItem extends StatelessWidget {

  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final Color? iconBackgroundColor;
  final VoidCallback? onPressed;
  
  const ClickableMenuItem({super.key, required this.title, required this.icon, this.trailing, this.onPressed, this.subtitle, this.iconBackgroundColor});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(

      decoration: BoxDecoration(
        //Colors.grey.shade200
        color: PreferencesProvider.getColor(context, 'primary-color'),
        borderRadius: BorderRadius.circular(8)
      ),

      child: ListTile(

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
        ),

        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),

        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,

          decoration: BoxDecoration(
            color: iconBackgroundColor ?? Colors.green.shade300,
            borderRadius: BorderRadius.circular(8)
          ),
          child: Icon(icon, color: Colors.white,)
        ),


        title: CustomText(
          title,
          fontSize: 16,
        ),


        subtitle: subtitle == null ? null : CustomText( 
          subtitle!,
          fontSize: 13,
        ),


        trailing: trailing ?? Icon(CupertinoIcons.forward),

        onTap: onPressed,
      ),
    );
  }
}







class RatingStars extends StatelessWidget {

  final double rating;
  final bool transparentBackground;
  final bool zeroPadding;
  final double spacing;

  const RatingStars({
    super.key,
    required this.rating,
    this.transparentBackground = false,
    this.zeroPadding = false,
    this.spacing = 5
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: zeroPadding ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 8, horizontal: 12),

      decoration: BoxDecoration(  
        color: transparentBackground ? Colors.transparent : PreferencesProvider.getColor(context, 'primary-color'),
        borderRadius: BorderRadius.circular(12)
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: spacing,
        children: List<Widget>.generate(5,  (index) => buildStar(index, rating)),
      )
    );
  }


  Widget buildStar(int index, double rating){

    IconData iconData = Icons.star_outline;
    bool shouldColor = false;

    int rateInt = rating.toInt();

    if(rating > index){

      iconData = Icons.star;

      //check whether the current should be halved.
      if((rating-rateInt) >= 0.5){
        iconData = Icons.star_half;
      }

      shouldColor = true;
    }

    return Icon(iconData, color: shouldColor ? Colors.green.shade400 : null,);
  }
}



