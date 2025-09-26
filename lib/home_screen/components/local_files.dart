import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:layerbase/home_screen/home_controller.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../utils/base/dialogs/base_dialog.dart';
import '../../utils/base/widgets/base_shader_mask.dart';
import '../../utils/base/widgets/base_text.dart';
import '../../utils/constants/app_color.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/constants/app_strings.dart';

class LocalFiles extends StatelessWidget {
  final HomeController controller;

  const LocalFiles({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Obx(
        () => Visibility(
          visible: controller.imageList.isNotEmpty,
          replacement: Container(
            padding: EdgeInsets.all(spacerSize10),
            width: double.infinity,
            decoration: baseBoxDecoration(
              color: AppColors.lightBlack,
              radius: spacerSize10,
              borderColor: Colors.transparent,
            ),
            child: Center(
              child: BaseText(
                text: AppStrings.noImageFound,
                fontSize: fontSize16,
                textColor: Colors.white,
              ),
            ),
          ),
          child: layerItemWidget(),
        ),
      ),
    );
  }

  Widget layerItemWidget() {
    return Container(
      padding: EdgeInsets.all(spacerSize10),
      width: double.infinity,
      decoration: baseBoxDecoration(
        color: AppColors.lightBlack,
        radius: spacerSize10,
        borderColor: Colors.transparent,
      ),
      child: MasonryGridView.count(
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: controller.imageList.length,
        itemBuilder: (context, index) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  controller.goToEditor(index);
                },
                child: Container(
                  height: (170 + (index % 3) * 70).toDouble(),
                  decoration: BoxDecoration(
                    color: AppColors.chineseBlack,
                    border: Border.all(color: AppColors.darkSlatePurple, width: 1),
                    borderRadius: BorderRadius.circular(spacerSize12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(spacerSize12),
                    child: FutureBuilder(
                      future: Future.delayed(const Duration(milliseconds: 0), () {
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
                          return const Center(child: Icon(Icons.broken_image));
                        }
                      },
                    ),
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(spacerSize12),
                    bottomRight: Radius.circular(spacerSize12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: AppStrings.information,
                      onPressed: () {
                        //   controller.downloadImage(controller.imageList[index]);
                      },
                      icon: Icon(Icons.info, color: AppColors.lightWhite, size: spacerSize15),
                    ),
                    BaseText(text: "", textColor: AppColors.lightWhite, fontSize: fontSize14),
                    IconButton(
                      tooltip: AppStrings.delete,
                      onPressed: () {
                        showBaseDialog(
                          context: context,
                          onNo: () => Get.back(),
                          onYes: () {
                            controller.hiveBox!.deleteAt(index);
                            controller.imageList.removeAt(index);
                            Get.back();
                          },
                          title: AppStrings.deleteImage,
                          subtitle: AppStrings.areYouSureWantTo + AppStrings.deleteThisImage,
                        );
                      },
                      icon: Icon(
                        Icons.delete_rounded,
                        color: AppColors.lightWhite,
                        size: spacerSize15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget shimmerPlaceHolder() {
    return Shimmer(
      color: AppColors.lightWhite,
      colorOpacity: 0.25,
      interval: Duration(milliseconds: 20),
      duration: Duration(milliseconds: 2700),
      child: Container(
        height: double.infinity,
        width: double.infinity,
        color: AppColors.lightBlack,
      ),
    );
  }
}
