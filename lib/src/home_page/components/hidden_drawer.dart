import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farmx/constants/constants.dart';
import 'package:farmx/constants/dimensions.dart';
import 'package:farmx/data/languages.dart';
import 'package:farmx/helper/lang_controller.dart';
import 'package:farmx/services/classify.dart';
import 'package:farmx/services/disease_provider.dart';
import 'package:farmx/services/hive_database.dart';
import 'package:farmx/src/home_page/models/disease_model.dart';
import 'package:farmx/src/suggestions_page/suggestions.dart';
import 'package:farmx/src/widgets/big_text.dart';
import 'package:farmx/src/widgets/small_text.dart';
import 'package:farmx/src/widgets/spacing.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HiddenDrawer extends StatefulWidget {
  const HiddenDrawer({super.key});

  @override
  State<HiddenDrawer> createState() => _HiddenDrawerState();
}

class _HiddenDrawerState extends State<HiddenDrawer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final translator = GoogleTranslator();

  LangController langController = Get.put(LangController());

  PackageInfo? packageInfo;

  String selectedOption = "";

  updateLocale(Locale locale, BuildContext context) {
    Get.updateLocale(locale);
  }

  void getPackage() async {
    packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo!.version;

    langController.setAppVersion(version);
  }

  @override
  void initState() {
    super.initState();
    getPackage();
  }

  @override
  Widget build(BuildContext context) {
    // Get disease from provider
    final diseaseService = Provider.of<DiseaseService>(context);

    // Hive service
    HiveService hiveService = HiveService();

    final Classifier classifier = Classifier();
    late Disease disease;

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
          color: Color.fromARGB(255, 2, 148, 46),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.height20,
          vertical: Dimensions.height45,
        ),
        child: langController.loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GetBuilder<LangController>(
                          builder: (_) => SmallText(
                                text:
                                    "version: ${langController.getAppVersion}",
                                fontStyle: FontStyle.italic,
                                size: Dimensions.font16 * 1.2,
                                color: AppColors.kWhite,
                              ))
                    ],
                  ),
                  SizedBox(
                    height: Dimensions.height45 * 15,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        verticalSpacing(Dimensions.height45 * 1.5),
                        SizedBox(
                          height: Dimensions.height45 * 3,
                          width: Dimensions.height45 * 3,
                          child: Center(
                            child: Image.asset(
                              "assets/images/plant.png",
                              height: Dimensions.height45 * 2.5,
                            ),
                          ),
                        ),
                        verticalSpacing(Dimensions.height45),
                        InkWell(
                            onTap: () => showModalBottomSheet(
                                context: context,
                                builder: (ctx) => _buildBottomSheet(ctx)),
                            child: Row(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.language,
                                  color: AppColors.kWhite,
                                ),
                                horizontalSpacing(Dimensions.width15),
                                SmallText(
                                  text: "chooseLanguage".tr,
                                  size: Dimensions.font16 * 1.2,
                                  color: AppColors.kWhite,
                                )
                              ],
                            )),
                        verticalSpacing(Dimensions.height30),
                        InkWell(
                          onTap: () async {
                            late double confidence;
                            await classifier
                                .getDisease(ImageSource.gallery)
                                .then((value) {
                              disease = Disease(
                                  name: value![0]["label"],
                                  imagePath: classifier.imageFile.path);

                              confidence = value[0]['confidence'];
                            });
                            // Check confidence
                            if (confidence > 0.8) {
                              // Set disease for Disease Service
                              diseaseService.setDiseaseValue(disease);

                              // Save disease
                              hiveService.addDisease(disease);

                              Navigator.restorablePushNamed(
                                context,
                                Suggestions.routeName,
                              );
                            } else {
                              // Display unsure message
                            }
                          },
                          child: Row(
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.file,
                                color: AppColors.kWhite,
                              ),
                              horizontalSpacing(Dimensions.width15),
                              SmallText(
                                text: "chooseImage".tr,
                                color: AppColors.kWhite,
                                size: Dimensions.font16 * 1.2,
                              )
                            ],
                          ),
                        ),
                        verticalSpacing(Dimensions.height30),
                        InkWell(
                          onTap: () async {
                            late double confidence;

                            await classifier
                                .getDisease(ImageSource.camera)
                                .then(
                              (value) {
                                disease = Disease(
                                    name: value![0]["label"],
                                    imagePath: classifier.imageFile.path);

                                confidence = value[0]['confidence'];
                              },
                            );

                            // Check confidence
                            if (confidence > 0.8) {
                              // Set disease for Disease Service
                              diseaseService.setDiseaseValue(disease);

                              // Save disease
                              hiveService.addDisease(disease);

                              Navigator.restorablePushNamed(
                                context,
                                Suggestions.routeName,
                              );
                            } else {
                              // Display unsure message
                            }
                          },
                          child: Container(
                            child: Row(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.camera,
                                  color: AppColors.kWhite,
                                ),
                                horizontalSpacing(Dimensions.width15),
                                SmallText(
                                  text: "takePhoto".tr,
                                  color: AppColors.kWhite,
                                  size: Dimensions.font16 * 1.2,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }

  // bottomsheet container

  Widget _buildBottomSheet(BuildContext context) {
    return SizedBox(
      height: Dimensions.height45 * 6,
      child: Column(
        children: [
          verticalSpacing(Dimensions.height10 * 2),
          BigText(
            text: "chooseLanguage".tr,
            color: AppColors.kMain,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20, vertical: Dimensions.height20),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: Dimensions.width20,
              children: Languages.options
                  .map((option) => buildChip(option.tr, context))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget buildChip(String option, BuildContext context) {
    bool isSelected = selectedOption == option;

    return GestureDetector(
      onTap: () async {
        setState(() {
          selectedOption = option;
        });

        Get.back();

        if (selectedOption == "English") {
          updateLocale(const Locale("en", "US"), context);
          langController.setLanguagecode("en");
        } else if (selectedOption == "Hindi") {
          updateLocale(const Locale("hi", "IN"), context);
          langController.setLanguagecode("hi");
        } else if (selectedOption == "Telugu") {
          updateLocale(const Locale("te", "IN"), context);
          langController.setLanguagecode("te");
        } else if (selectedOption == "Gujarati") {
          updateLocale(const Locale("gu", "IN"), context);
          langController.setLanguagecode("gu");
        } else if (selectedOption == "Marathi") {
          updateLocale(const Locale("mr", "IN"), context);
          langController.setLanguagecode("mr");
        }
      },
      child: Chip(
        backgroundColor: isSelected ? AppColors.kMain : AppColors.kWhite,
        shape: const StadiumBorder(
            side: BorderSide(
          color: AppColors.kMain,
        )),
        label: Text(
          option,
          style: TextStyle(
            color: isSelected ? AppColors.kWhite : AppColors.kMain,
            fontSize: Dimensions.font16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
