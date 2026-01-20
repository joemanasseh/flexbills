import '../../utils/basic_widget_imports.dart';

class TextValueFormWidget extends StatelessWidget {
  const TextValueFormWidget(
      {super.key,
      required this.text,
        this.value = "",
        this.currency = ""
      });

  final String text, value, currency;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TitleHeading4Widget(
          opacity: .6,
          text: text,
          fontSize: Dimensions.headingTextSize4 * .85,
          fontWeight: FontWeight.w500,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                visible: value.isNotEmpty,
                child: TitleHeading3Widget(
                  opacity: .6,
                  text: value,
                  fontSize: Dimensions.headingTextSize3 * .85,
                  fontWeight: FontWeight.w600,
                  color: CustomColor.secondaryLightTextColor,
                ),
              ),
              Visibility(
                visible: currency.isNotEmpty,
                child: TitleHeading3Widget(
                  opacity: .6,
                  text: " $currency",
                  fontSize: Dimensions.headingTextSize3 * .85,
                  textAlign: TextAlign.end,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
