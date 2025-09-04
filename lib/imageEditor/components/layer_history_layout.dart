import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerbase/imageEditor/components/side_layer_list.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../utils/base/widgets/base_text.dart';
import '../../utils/constants/app_color.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/constants/app_strings.dart';
import '../image_editor_view_model.dart';

class LayerHistoryLayout extends StatelessWidget {
  const LayerHistoryLayout({super.key, this.controller});

  final ImageEditorViewModel? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.chineseBlack,
          border: Border.all(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(spacerSize8),
        ),
        child: Obx(() {
          return (controller!.isLoading.value ||
                  controller!.activeLayersList!.isEmpty)
              ? buildShimmerEffect(context)
              : SidLayerList(controller: controller!);
        }),
      ),
    );
  }

  Widget buildShimmerEffect(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(spacerSize8),
              topRight: Radius.circular(spacerSize8),
            ),
            color: AppColors.darkJungleGreen,
          ),
          child: const BaseText(
            text: AppStrings.layerHistory,
            textColor: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: controller!.isLoading.value
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: spacerSize10,
                    vertical: spacerSize10,
                  ),
                  itemCount: 10,
                  itemBuilder: (context, index) => buildShimmerItem(),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: spacerSize10),
                )
              : const Center(
                  child: BaseText(
                    text: AppStrings.noLayers,
                    textColor: Colors.white,
                    fontSize: spacerSize12,
                  ),
                ),
        ),
      ],
    );
  }

  Widget buildShimmerItem() {
    return Shimmer(
      color: AppColors.lightGrey,
      interval: Duration(milliseconds: 20),
      duration: Duration(milliseconds: 2700),
      colorOpacity: 0.16,
      enabled: true,
      direction: const ShimmerDirection.fromLTRB(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: spacerSize8,
          horizontal: spacerSize8,
        ),
        decoration: BoxDecoration(
          color: AppColors.darkJungleGreen,
          borderRadius: BorderRadius.circular(spacerSize8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              spacing: spacerSize12,
              children: [shimmerLayout(), shimmerLayout(), shimmerLayout()],
            ),
            const SizedBox(width: spacerSize8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(spacerSize4),
                child: Container(
                  height: spacerSize65,
                  color: AppColors.chineseBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  shimmerLayout() {
    return Container(
      width: spacerSize12,
      height: spacerSize12,
      decoration: BoxDecoration(
        color: AppColors.chineseBlack,
        borderRadius: BorderRadius.circular(spacerSize4),
      ),
    );
  }
}
