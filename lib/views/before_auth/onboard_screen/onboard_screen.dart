import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:adescrow_app/utils/responsive_layout.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';

import '../../../backend/services/api_endpoint.dart';
import '../../../widgets/others/custom_cached_network_image.dart';
import '../../../controller/before_auth/basic_settings_controller.dart';
import '../../../controller/before_auth/onboard_screen_controller.dart';
import '../../../utils/svg_assets.dart';
import '../../../widgets/text_labels/title_sub_title_widget.dart';

String _sanitize(String text) => text
    .replaceAll('Escroc App', 'Flexbills')
    .replaceAll('Escroc', 'Flexbills')
    .replaceAll('escroc', 'Flexbills')
    .replaceAll('AdesEscrow', 'Flexbills')
    .replaceAll('Adescrow', 'Flexbills')
    .replaceAll('adescrow', 'Flexbills');

class OnboardScreen extends StatelessWidget {
  const OnboardScreen({super.key});

  bool _isValidIndex(int index, int length) {
    return index >= 0 && index < length;
  }

  @override
  Widget build(BuildContext context) {
    var basicController = Get.find<BasicSettingsController>();
    var basicSettings = basicController.basicSettingModel;

    // Show loading or error state if basicSettings is null
    if (basicSettings == null) {
      return ResponsiveLayout(
        mobileScaffold: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Loading onboarding screens...'),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    basicController.basicSettingsFetch();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Check if onboardScreen list is empty
    if (basicSettings.data.onboardScreen.isEmpty) {
      return ResponsiveLayout(
        mobileScaffold: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No onboarding screens available'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Get.find<OnboardController>().goNextBTNClicked();
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ResponsiveLayout(
      mobileScaffold: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            Obx(() {
              final index = basicController.selectedIndex.value;
              if (!_isValidIndex(
                  index, basicSettings.data.onboardScreen.length)) {
                return Container();
              }
              return CustomCachedNetworkImage(
                imageUrl:
                    "${ApiEndpoint.mainDomain}/${basicSettings.data.imagePath}/${basicSettings.data.onboardScreen[index].image}",
              );
            }),
            Obx(() {
              final index = basicController.selectedIndex.value;
              if (!_isValidIndex(
                  index, basicSettings.data.onboardScreen.length)) {
                return Container();
              }
              return Positioned(
                bottom: 230,
                width: MediaQuery.of(context).size.width,
                child: TitleSubTitleWidget(
                  title: _sanitize(basicSettings.data.onboardScreen[index].title),
                  subTitle: _sanitize(basicSettings.data.onboardScreen[index].subTitle),
                ),
              );
            }),
            Positioned(
              bottom: 150,
              right: 0,
              left: 0,
              child: InkWell(
                  borderRadius: BorderRadius.circular(Dimensions.radius * 10),
                  onTap: () {
                    if ((basicController.selectedIndex.value + 1) ==
                        basicSettings.data.onboardScreen.length) {
                      Get.find<OnboardController>().goNextBTNClicked();
                    } else {
                      basicController.selectedIndex.value++;
                    }
                  },
                  child: Animate(
                      effects: const [FadeEffect(), ScaleEffect()],
                      child: SvgPicture.string(SVGAssets.circleButton))),
            )
          ],
        ),
      ),
    );
  }
}
