
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/providers/pref_provider.dart';


class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(  
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          HeaderText('Files', fontSize: 25,),


          const SizedBox(height: 12,),


          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: CustomTextField(  
              controller: TextEditingController(),
              hintText: 'Search Files',
              leadingIcon: Icons.search,
            ),
          ),


          const SizedBox(height: 12,),

          Expanded(  
            child: Container(  
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PreferencesProvider.getColor(context, 'table-background-color'),
                borderRadius: BorderRadius.circular(12)
              ),
              child: Column(  
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container( 
                    padding: const EdgeInsets.all(8), 
                    decoration: BoxDecoration(
                      color: PreferencesProvider.getColor(context, 'table-header-color'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(  
                          flex: 2,
                          child: CustomText('File Name'),
                        ),


                        SizedBox(
                          width: 200,
                          child: CustomText('File Type'),
                        ),


                        Expanded(  
                          flex: 2,
                          child: CustomText('Directory'),
                        ),



                        SizedBox(
                          width: 130,
                          child: CustomText('Action', textAlignment: TextAlign.center,),
                        ),



                      ],
                    ),
                  ),

                  const SizedBox(height: 8,),


                  if(Provider.of<PreferencesProvider>(context).preferences.savedFiles.isEmpty) Expanded(  
                    child: CollectionPlaceholder(
                      title: 'No Files!',
                      detail: 'All saved or exported files appear here.',
                    )
                  )
                  else Expanded(
                    flex: 2,
                    child: ListView.separated(  
                      itemCount: Provider.of<PreferencesProvider>(context).preferences.savedFiles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8,),
                      itemBuilder: (_, index){
                    
                        String fullFilePath = Provider.of<PreferencesProvider>(context, listen:false).preferences.savedFiles[index];
                        
                        String fileDir = fullFilePath.substring(0, fullFilePath.lastIndexOf('/')+1);
                    
                        String fileName = fullFilePath.substring(fullFilePath.lastIndexOf('/')+1, fullFilePath.length);
                    
                        String fileExtension = fileName.substring(fileName.lastIndexOf('.'), fileName.length);
                    
                        fileName = fileName.substring(0, fileName.lastIndexOf('.'));
                    
                    
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                        
                            Expanded(  
                              flex: 2, 
                              child: CustomText(
                                fileName
                              ),
                            ),
                                            
                                            
                            SizedBox(
                              width: 200,  
                              child: CustomText(
                                fileExtension,
                              ),
                            ),
                            
                            Expanded(  
                              flex: 2,
                              child: CustomText(
                                fileDir
                              ),
                            ),
                        
                            
                            SizedBox(
                              width: 130,
                              child: Container(  
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: PreferencesProvider.getColor(context, 'alt-primary-color'),
                                  borderRadius: BorderRadius.circular(12)
                                ),
                              
                                child: Row(  
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                              
                                    IconButton(  
                                      onPressed: (){},
                                      tooltip: 'Open File',
                                      icon: Icon(Icons.open_in_new, size: 20,),
                                    ),
                              
                                    IconButton(  
                                      onPressed: (){},
                                      tooltip: 'Open containing folder',
                                      icon: Icon(Icons.folder, size: 20,),
                                    ),
                              
                                    IconButton(  
                                      onPressed: (){},
                                      tooltip: 'Delete File',
                                      icon: Icon(Icons.delete, size: 20, color: Colors.red.shade400,),
                                    ),
                              
                                  ],
                                )
                              ),
                            ),
                        
                        
                                                
                          ],
                        );
                    
                    
                      }
                    ),
                  )

                ],
              ),
            ),
          )

        ],
      ),
    );
  }



  void handleOpen(){

  }


  void handleOpenFolder(){

  }


  void handleDelete(){

  }

}