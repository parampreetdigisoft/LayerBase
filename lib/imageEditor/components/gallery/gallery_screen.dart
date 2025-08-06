import 'package:flutter/foundation.dart';
import 'package:layerbase/imageEditor/components/cloud_storage_access_tooltip.dart';
import 'package:layerbase/imageEditor/components/gallery/gallery_screen_view_model.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/constants/app_strings.dart';
import 'package:layerbase/utils/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GalleryScreen extends GetWidget<GalleryScreenViewModel> {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(spacerSize25),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Scaffold(
        body: Container(
          color: AppColors.chineseBlack,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: spacerSize50,
                  width: spacerSize400,
                  padding: const EdgeInsets.all(spacerSize4),
                  decoration: BoxDecoration(
                    color: AppColors.chineseBlack,
                    borderRadius: BorderRadius.circular(spacerSize10),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: TabBar(
                    onTap: (index) {
                      if (index == 1 &&
                          (defaultTargetPlatform == TargetPlatform.linux
                              ? controller.sharedPrefsService
                                    .getString(AppKeys.idToken)!
                                    .isEmpty
                              : FirebaseAuth.instance.currentUser == null)) {
                        _showCloudFeatureDialog(context);
                      }
                    },
                    enableFeedback: false,
                    controller: controller.tabController,
                    indicator: BoxDecoration(
                      color: AppColors.darkJungleGreen,
                      borderRadius: BorderRadius.circular(spacerSize10),
                    ),
                    labelColor: Colors.white,
                    dividerColor: Colors.transparent,
                    indicatorColor: Colors.transparent,
                    unselectedLabelColor: AppColors.grey,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    indicatorSize: TabBarIndicatorSize.tab,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    automaticIndicatorColorAdjustment: true,
                    tabs: const [
                      Tab(text: AppStrings.localFiles),
                      Tab(text: AppStrings.cloudFiles),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: spacerSize24),
              Expanded(
                child: TabBarView(
                  controller: controller.tabController,
                  children: [buildHistoryGallery(), buildHistoryGallery()],
                ),
              ),
            ],
          ),
        ),
      ).marginAll(spacerSize20),
    ).marginAll(spacerSize10);
  }

  Widget buildHistoryGallery() {
    return Obx(
      () => GridView.builder(
        scrollDirection: Axis.vertical,
        itemCount: controller.imageList!.length,
        itemBuilder: (context, imageIndex) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.imageEditor,
                arguments: {
                  AppKeys.imageData: controller.hiveBox!.getAt(imageIndex),
                  AppKeys.imageData: controller.hiveBox!.getAt(imageIndex),
                  AppKeys.imageIndex: imageIndex,
                },
              ).then((value) {
                controller.fetchImagesFromDb();
              });
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.darkBlue),
                    borderRadius: BorderRadius.circular(spacerSize5),
                  ),
                  child: Image.memory(
                    controller.imageList![imageIndex],
                    fit: BoxFit.fitWidth,
                    height: double.infinity,
                    width: double.infinity,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Positioned(
                  top: spacerSize4,
                  right: spacerSize4,
                  child: GestureDetector(
                    onTap: () {
                      controller.imageList!.removeAt(imageIndex);
                      controller.hiveBox!.deleteAt(imageIndex);
                      controller.imageList!.refresh();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(spacerSize2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Tooltip(
                        message: AppStrings.delete,
                        mouseCursor: MouseCursor.defer,
                        child: const Icon(
                          Icons.delete_forever,
                          color: AppColors.darkBlue,
                          size: spacerSize16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
        ),
        shrinkWrap: true,
      ),
    );
  }

  void _showCloudFeatureDialog(BuildContext context) {
    final RenderBox tabBarBox = context.findRenderObject() as RenderBox;
    final Offset tabBarPosition = tabBarBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        spacerSize300,
        tabBarPosition.dy + spacerSize75,
        tabBarPosition.dx + tabBarBox.size.width / spacerSize2 + spacerSize100,
        tabBarPosition.dy,
      ),
      color: Colors.transparent,
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: CloudStorageAccessTooltip(),
        ),
      ],
      elevation: 0,
    ).then((value) {
      if (value == null && controller.tabController.index == 1) {
        controller.tabController.animateTo(0);
      }
    });
  }
}
