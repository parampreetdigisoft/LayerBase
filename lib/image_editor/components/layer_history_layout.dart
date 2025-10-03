import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerbase/image_editor/components/side_layer_list.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../utils/base/widgets/base_shader_mask.dart';
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
    return Container(
      decoration: baseBoxDecoration(
        color: AppColors.lightBlack,
        radius: spacerSize8,
        borderColor: AppColors.lightBlack,
      ),
      child: Obx(() {
        return (controller!.isLoading.value || controller!.activeLayersList!.isEmpty)
            ? buildShimmerEffect(context)
            : SidLayerList(controller: controller!);
      }),
    );
  }

  buildShimmerEffect(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(spacerSize8),
              topRight: Radius.circular(spacerSize8),
            ),
            color: AppColors.lightGrey,
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
                  padding: EdgeInsets.symmetric(horizontal: spacerSize10, vertical: spacerSize10),
                  itemCount: 10,
                  itemBuilder: (context, index) => buildShimmerItem(),
                  separatorBuilder: (context, index) => const SizedBox(height: spacerSize10),
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

  buildShimmerItem() {
    return Shimmer(
      color: AppColors.lightWhite,
      interval: Duration(milliseconds: 20),
      duration: Duration(milliseconds: 2700),
      colorOpacity: 0.16,
      enabled: true,
      direction: const ShimmerDirection.fromLTRB(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: spacerSize8, horizontal: spacerSize8),
        decoration: baseBoxDecoration(
          color: AppColors.lightGrey,
          radius: spacerSize8,
          borderColor: AppColors.lightBlack1,
        ),
        child: Row(
          spacing: spacerSize10,
          children: [
            shimmerLayout(),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(spacerSize4),
                child: Container(height: spacerSize45, color: AppColors.lightBlack),
              ),
            ),
            shimmerLayout(),
            shimmerLayout(),
          ],
        ),
      ),
    );
  }

  shimmerLayout() {
    return Container(
      width: spacerSize12,
      height: spacerSize12,
      decoration: baseBoxDecoration(
        color: AppColors.lightBlack1,
        radius: spacerSize4,
        borderColor: AppColors.lightBlack1,
      ),
    );
  }
}
