import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../utils/basic_screen_imports.dart';
import 'custom_dropdown_widget.dart';

class WalletDropDown<T extends DropdownModel> extends StatefulWidget {
  final String hint, image;
  final Color? borderColor;
  final List<T> items;
  final void Function(T?) onChanged;
  final BoxBorder? border;
  final double? fieldBorderRadius;
  final Color? dropDownIconColor;
  final Color? titleTextColor;
  final Color dropDownFieldColor;
  final Color? dropDownColor;
  final bool borderEnable;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? customBorderRadius;
  const WalletDropDown({
    super.key,
    required this.items,
    required this.onChanged,
    this.border,
    this.fieldBorderRadius,
    this.dropDownIconColor,
    this.titleTextColor,
    this.dropDownFieldColor = Colors.transparent,
    this.padding,
    this.margin,
    this.borderColor,
    this.dropDownColor,
    required this.hint,
    this.borderEnable = true,
    this.customBorderRadius,
    required this.image,
  });

  @override
  // ignore: library_private_types_in_public_api
  _WalletDropDownState<T> createState() => _WalletDropDownState<T>();
}

class _WalletDropDownState<T extends DropdownModel>
    extends State<WalletDropDown<T>> {
  T? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return _dropDown();
  }

  Widget _avatarWidget(BuildContext context,
      {required String imageUrl, required String fallbackLetter}) {
    final double r = Dimensions.iconSizeDefault * .85;
    final double size = r * 2;
    if (imageUrl.isEmpty) {
      return CircleAvatar(
        backgroundColor: CustomColor.whiteColor,
        radius: r,
        child: Text(
          fallbackLetter.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }
    return CircleAvatar(
      backgroundColor: CustomColor.whiteColor,
      radius: r,
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Text(
            fallbackLetter.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  _dropDown() {
    return Container(
      height: Dimensions.inputBoxHeight * 0.7,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.only(
        right: 5
      ),
      decoration: BoxDecoration(
        color: widget.dropDownFieldColor,
        border: widget.borderEnable
            ? widget.border ??
                Border.all(
                  color: widget.borderColor ??
                      (CustomColor.whiteColor.withOpacity(0.3)),
                  width: 1.5,
                )
            : null,
        borderRadius: widget.customBorderRadius ??
            BorderRadius.circular(
              widget.fieldBorderRadius ?? Dimensions.radius * 2,
            ),
      ),
      child: DropdownButtonHideUnderline(

        child: DropdownButton2<T>(
          hint: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Animate(
                effects: const [FadeEffect(), ScaleEffect()],
                child: _avatarWidget(
                  context,
                  imageUrl: widget.image,
                  fallbackLetter: widget.hint.isNotEmpty ? widget.hint[0] : '?',
                ),
              ).paddingZero,
              horizontalSpace(Dimensions.marginSizeHorizontal * .3),
              Text(
                widget.hint,
                style: Get.isDarkMode
                    ? CustomStyle.darkHeading4TextStyle.copyWith(
                        color: widget.titleTextColor ??
                            Theme.of(context).primaryColor,
                      )
                    : CustomStyle.lightHeading4TextStyle.copyWith(
                        color: widget.titleTextColor ??
                            Theme.of(context).primaryColor,
                      ),
              ),
            ],
          ).paddingZero,
          value: _selectedItem,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: Dimensions.headingTextSize3,
            fontWeight: FontWeight.w500,
          ),
          iconStyleData: IconStyleData(
            icon: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.arrow_drop_down_rounded,
                color: widget.dropDownIconColor ??
                    (_selectedItem != null
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor),
              ),
            ),
          ),

          dropdownStyleData: DropdownStyleData(
            padding: EdgeInsets.zero,
            maxHeight: MediaQuery.sizeOf(context).height * .25,
            decoration: BoxDecoration(
              color: widget.dropDownColor ?? CustomColor.whiteColor,
              borderRadius: BorderRadius.circular(Dimensions.radius),
            ),
          ),
          underline: Container().paddingZero,
          onChanged: (T? newValue) {
            setState(() {
              _selectedItem = newValue;
              widget.onChanged(_selectedItem);
            });
          },
          items: widget.items.map<DropdownMenuItem<T>>(
            (T value) {
              return DropdownMenuItem<T>(
                  value: value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Animate(
                        effects: const [FadeEffect(), ScaleEffect()],
                        child: _avatarWidget(
                          context,
                          imageUrl: value.img,
                          fallbackLetter: value.title.isNotEmpty ? value.title[0] : '?',
                        ),
                      ),
                      horizontalSpace(Dimensions.marginSizeHorizontal * .4),
                      Text(
                        value.title,
                        style: TextStyle(
                            color: widget.titleTextColor ??
                                Theme.of(context).primaryColor),
                      ),
                    ],
                  ).paddingZero);
            },
          ).toList(),
        ).paddingZero,
      ).paddingZero,
    );
  }
}
