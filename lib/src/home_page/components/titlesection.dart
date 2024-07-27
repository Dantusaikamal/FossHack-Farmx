import 'package:flutter/material.dart';
import 'package:farmx/constants/constants.dart';
import 'package:farmx/constants/dimensions.dart';
import 'package:farmx/src/widgets/big_text.dart';

class TitleSection extends StatelessWidget {
  final String title;
  const TitleSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
      ),
      child: BigText(
        text: title,
        color: AppColors.kMain,
        size: Dimensions.font26,
      ),
    );
  }
}
