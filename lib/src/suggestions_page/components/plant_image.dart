import 'dart:io';

import 'package:flutter/material.dart';
import 'package:farmx/constants/constants.dart';

class PlantImage extends StatelessWidget {
  const PlantImage(
      {super.key,
      required this.size,
      required this.imageFile,
      required this.borderColor});

  final Size size;
  final File imageFile;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        border: Border.all(
          width: 5,
          color: AppColors.kMain,
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(2, 2),
            blurRadius: 15,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: size.width * 0.3,
        backgroundImage: Image.file(
          imageFile,
          fit: BoxFit.cover,
        ).image,
      ),
    );
  }
}
