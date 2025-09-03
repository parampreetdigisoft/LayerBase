import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerbase/utils/constants/app_assets.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_strings.dart';

import '../utils/base/widgets/base_text.dart';
import '../utils/routes.dart';
import 'components/cloud_files.dart';
import 'components/local_files.dart';
import 'home_controller.dart';

class HomeScreen extends GetWidget<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkJungleGreen,
      appBar: appBarWidget(context),
      body: Obx(() {
        return DefaultTabController(
          initialIndex: controller.selectedIndex.value,
          length: 2,
          child: Row(
            children: [
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                ),
                onPressed: () {
                  controller.onClickPickImageOpen();
                },
                icon: Container(
                  margin: EdgeInsets.symmetric(horizontal: spacerSize15),
                  padding: EdgeInsets.symmetric(
                    horizontal: spacerSize25,
                    vertical: spacerSize5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.chineseBlack,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(spacerSize10),
                      topRight: Radius.circular(spacerSize10),
                    ),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Column(
                    children: [
                      BaseText(
                        text: AppStrings.fileUpload,
                        textColor: AppColors.antiqueWhite,
                        fontWeight: FontWeight.w500,
                        fontSize: fontSize16,
                      ),
                      Spacer(),
                      Image.asset(
                        AppAssets.uploadIcon,
                        height: spacerSize50,
                        width: spacerSize50,
                        color: AppColors.grey,
                      ),
                      SizedBox(height: spacerSize5),
                      BaseText(
                        text: AppStrings.selectImageDesc,
                        textAlign: TextAlign.center,
                        textColor: AppColors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: spacerSize12,
                      ),
                      SizedBox(height: spacerSize12),
                      Tooltip(
                        message: AppStrings.clickHereToBrowseAnImage,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacerSize20,
                            vertical: spacerSize10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.violet, AppColors.brightCyan],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(spacerSize30),
                          ),

                          child: Text(
                            AppStrings.browseImage,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: spacerSize12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: spacerSize20),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: spacerSize12),
                  child: Column(
                    children: [
                      buildCustomTabBar(),
                      SizedBox(height: spacerSize10),
                      Expanded(
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            LocalFiles(controller: controller),
                            CloudFiles(controller: controller),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildCustomTabBar() {
    return Container(
      padding: const EdgeInsets.all(spacerSize5),
      decoration: BoxDecoration(
        color: AppColors.chineseBlack,
        borderRadius: BorderRadius.circular(spacerSize10),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: TabBar(
        onTap: (index) {
          controller.changeTab(index);
        },
        enableFeedback: false,
        indicator: BoxDecoration(
          color: AppColors.darkJungleGreen,
          borderRadius: BorderRadius.circular(spacerSize10),
        ),
        labelColor: AppColors.antiqueWhite,
        unselectedLabelColor: AppColors.grey,
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,

        labelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: fontSize14,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        automaticIndicatorColorAdjustment: true,
        tabs: controller.tabLabels.map((label) => Tab(text: label)).toList(),
      ),
    );
  }

  AppBar appBarWidget(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkJungleGreen,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Image.asset(AppAssets.appLogo, height: spacerSize25),
      actions: [
        Obx(
          () => IconButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.only(right: spacerSize5),
              minimumSize: Size(0, 0),
            ),
            tooltip: controller.userDisplayName.value.isEmpty
                ? AppStrings.login
                : AppStrings.logout,
            onPressed: () {
              if (controller.userDisplayName.value.isEmpty) {
                Navigator.pushNamed(context, Routes.logIn);
              } else {
                controller.showLogoutDialog();
              }
            },

            icon: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  controller.userDisplayName.value.isEmpty
                      ? Icons.person
                      : Icons.logout,
                  size: spacerSize15,
                  color: AppColors.antiqueWhite,
                ),
                BaseText(
                  text: controller.userDisplayName.value.isEmpty
                      ? AppStrings.login
                      : AppStrings.logout,
                  textColor: AppColors.antiqueWhite,
                  fontWeight: FontWeight.w500,
                  fontSize: fontSize14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
