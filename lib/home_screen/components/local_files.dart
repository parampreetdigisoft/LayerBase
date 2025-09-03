import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerbase/home_screen/home_controller.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../utils/base/dialogs/base_dialog.dart';
import '../../utils/base/widgets/base_text.dart';
import '../../utils/constants/app_color.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/constants/app_keys.dart';
import '../../utils/constants/app_strings.dart';
import '../../utils/routes.dart';

class LocalFiles extends StatelessWidget {
  final HomeController controller;

  const LocalFiles({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkJungleGreen,
      body: Obx(
        () => Container(
          padding: EdgeInsets.all(spacerSize10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.chineseBlack,
            border: Border.all(color: AppColors.lightGrey),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(spacerSize10),
              topRight: Radius.circular(spacerSize10),
            ),
          ),

          child: Visibility(
            visible: controller.imageList.isNotEmpty,
            replacement: Center(
              child: BaseText(
                text: AppStrings.noImageFound,
                fontSize: fontSize16,
                textColor: Colors.white,
              ),
            ),
            child: layerItemWidget(),
          ),
        ),
      ),
    );
  }

  Widget layerItemWidget() {
    return GridView.builder(
      itemCount: controller.imageList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return Stack(
          children: [
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.imageEditor,
                  arguments: {AppKeys.imageIndex: index},
                ).then((value) {
                  controller.fetchImagesFromDb();
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.chineseBlack,
                  border: Border.all(color: AppColors.lightGrey),
                  borderRadius: BorderRadius.circular(spacerSize12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(spacerSize12),
                  child: FutureBuilder(
                    future: Future.delayed(const Duration(milliseconds: 300), () {
                      return controller.imageList[index];
                    }),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return shimmerPlaceHolder();
                      } else if (snapshot.hasData) {
                        return Image.memory(
                          snapshot.data as Uint8List,
                          filterQuality: FilterQuality.medium,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        );
                      } else {
                        return const Center(child: Icon(Icons.broken_image, color: Colors.white));
                      }
                    },
                  ),
                ),
              ),
            ),

            // Action buttons overlay
            Container(
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(spacerSize12),
                  topRight: Radius.circular(spacerSize12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: AppStrings.download,
                    onPressed: () {
                      controller.downloadImage(controller.imageList[index]);
                    },
                    icon: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [AppColors.violet, AppColors.brightCyan, AppColors.antiqueWhite],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.arrow_circle_down_sharp,
                        color: Colors.white,
                        size: spacerSize20,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: AppStrings.delete,
                    onPressed: () {
                      showCommonDialog(
                        context: context,
                        onNo: () => Get.back(),
                        onYes: () {
                          controller.imageList.removeAt(index);
                          controller.hiveBox!.deleteAt(index);
                          controller.imageList.refresh();
                          Get.back();
                        },
                        title: AppStrings.deleteImage,
                        subtitle: AppStrings.areYouSureWantTo + AppStrings.deleteThisImage,
                      );
                    },
                    icon: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [AppColors.violet, AppColors.brightCyan, AppColors.antiqueWhite],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                        size: spacerSize20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget shimmerPlaceHolder() {
    return Shimmer(
      color: AppColors.lightGrey,
      colorOpacity: 0.16,
      interval: Duration(milliseconds: 20),
      duration: Duration(milliseconds: 2700),
      child: Container(
        height: double.infinity,
        width: double.infinity,
        color: AppColors.darkJungleGreen,
      ),
    );
  }
}
