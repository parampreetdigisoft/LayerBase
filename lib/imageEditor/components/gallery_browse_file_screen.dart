import 'package:layerbase/base/widgets/base_text.dart';
import 'package:layerbase/components/bottom_navigation_sheet.dart';
import 'package:layerbase/imageEditor/components/gallery/gallery_screen.dart';
import 'package:layerbase/imageEditor/components/gallery/gallery_screen_view_model.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GalleryBrowseFileScreen extends GetWidget<GalleryScreenViewModel> {
  const GalleryBrowseFileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkJungleGreen,
      appBar: AppBar(
        backgroundColor: AppColors.darkJungleGreen,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        height: spacerSize50,
        color: AppColors.darkJungleGreen,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[BottomNavigationSheet()],
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: spacerSize50, right: spacerSize50),
        decoration: BoxDecoration(
          color: Colors.transparent,
          // border: Border.all(color: AppColors.darkGunMetal),
          borderRadius: BorderRadius.circular(spacerSize25),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.chineseBlack,
            border: Border.all(color: AppColors.darkGunMetal),
            borderRadius: BorderRadius.circular(spacerSize25),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.all(spacerSize25),
                  decoration: BoxDecoration(
                    color: AppColors.darkGunMetal,
                    border: Border.all(color: AppColors.chineseBlack),
                    borderRadius: BorderRadius.circular(spacerSize25),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      IconButton(
                        onPressed: controller.pickImage,
                        color: Colors.white,
                        iconSize: spacerSize60,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        icon: Icon(Icons.upload_file_rounded),
                      ),
                      BaseText(
                        text: AppStrings.browseImage,
                        textColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  margin: EdgeInsets.all(spacerSize10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(spacerSize25),
                  ),
                  child: GalleryScreen(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
