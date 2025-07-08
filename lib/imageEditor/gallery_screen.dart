import 'dart:typed_data';

import 'package:ecrumedia/base/widgets/base_text.dart';
import 'package:ecrumedia/imageEditor/gallery_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class GalleryScreen extends GetWidget<GalleryScreenViewModel> {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: const BaseText(text: 'Gallery'),
              pinned: true,
              floating: true,
              bottom: TabBar(
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone_android, color: Colors.indigo.shade500),
                        const SizedBox(width: 8),
                        const BaseText(text: 'Local'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, color: Colors.indigo.shade500),
                        const SizedBox(width: 8),
                        const BaseText(text: 'Cloud'),
                      ],
                    ),
                  ),
                ],
          controller: controller.tabController,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: controller.tabController,
          children: [
            SizedBox(child: BaseText(text: 'Local Content')),
            SizedBox(child: BaseText(text: 'Cloud Content')),
          ],
        ),
      ),
    );
  }

  Widget buildHistoryGallery() {
    final box = Hive.box<Uint8List>('imageBox');

    return GridView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: box.length,
      itemBuilder: (context, index) {
        Uint8List? image = box.getAt(index);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: image != null
              ? Image.memory(image, fit: BoxFit.fill)
              : Container(),
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      shrinkWrap: true,
    );
  }
}
