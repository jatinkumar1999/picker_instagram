import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../camera_image_video_picker.dart';
import '../insta_image_picker_controller.dart';

class CameraAndMultipleSelectionView extends StatelessWidget {
  final InstagramImagePickerController controller;
  final Function(List<SetImageModal>?) onComplete;

  final Function? removeVideoListener;
  const CameraAndMultipleSelectionView(
      {super.key,
      required this.controller,
      required this.onComplete,
      this.removeVideoListener});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: CustomHeaderDelegate(
        minHeight: 80.0,
        maxHeight: 80.0,
        child: Container(
          height: 80.0,
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  controller.setMultipleSelection(false);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 35,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    // vertical: 5,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    color: controller.isMultipleSelection
                        ? Colors.blue
                        : const Color(0xff1E1E1E),
                  ),
                  child: Text(
                    'SELECT MULTIPLE',
                    style: GoogleFonts.laila(
                      fontSize: 10,
                      color: controller.isMultipleSelection
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: !controller.isMultipleSelection
                    ? () {
                        if (removeVideoListener != null) {
                          removeVideoListener!();
                        }
                        controller.removeVideoController();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CameraScreen(),
                          ),
                        ).then(
                          (value) {
                            if (value != null) {
                              onComplete(value);
                            }
                          },
                        );
                      }
                    : () {},
                child: Container(
                  width: 35,
                  height: 35,
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xff1E1E1E),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.camera,
                      color: !controller.isMultipleSelection
                          ? Colors.white
                          : Colors.grey.withOpacity(0.45),
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }
}
