import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmx/constants/constants.dart';
import 'package:farmx/constants/dimensions.dart';
import 'package:farmx/helper/lang_controller.dart';
import 'package:farmx/services/disease_provider.dart';
import 'package:farmx/src/home_page/components/greeting.dart';
import 'package:farmx/src/home_page/components/history.dart';
import 'package:farmx/src/home_page/components/instructions.dart';
import 'package:farmx/src/home_page/components/titlesection.dart';
import 'package:farmx/src/widgets/spacing.dart';
import 'package:provider/provider.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    // Get disease from provider
    final _diseaseService = Provider.of<DiseaseService>(context);

    // Data
    Size size = MediaQuery.of(context).size;

    return GetBuilder<LangController>(
      builder: (langController) => langController.loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/bg.jpg'),
                    fit: BoxFit.cover),
                color: AppColors.kWhite,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GreetingSection(),
                  verticalSpacing(Dimensions.height30),
                  TitleSection(title: "instructionTitle".tr),
                  InstructionsSection(),
                  verticalSpacing(Dimensions.height30),
                  TitleSection(
                    title: "historyTitle".tr,
                  ),
                  verticalSpacing(Dimensions.height20),
                  HistorySection(size: size, diseaseService: _diseaseService)
                ],
              ),
            ),
    );
  }
}
