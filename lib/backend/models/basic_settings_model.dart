
class BasicSettingModel {
  Data data;
  Message message;

  BasicSettingModel({
    required this.data,
    required this.message,
  });

  factory BasicSettingModel.fromJson(Map<String, dynamic> json) =>
      BasicSettingModel(
        data: Data.fromJson(json["data"]),
        message: Message.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "message": message.toJson(),
      };
}

class Data {
  AllLogo allLogo;
  AppUrl appUrl;
  String defaultImage;
  String imagePath;
  String logoImagePath;
  List<OnboardScreen> onboardScreen;
  SplashScreen splashScreen;

  Data({
    required this.allLogo,
    required this.appUrl,
    required this.defaultImage,
    required this.imagePath,
    required this.logoImagePath,
    required this.onboardScreen,
    required this.splashScreen,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        allLogo: AllLogo.fromJson(json["all_logo"]),
        appUrl: AppUrl.fromJson(json["app_url"]),
        defaultImage: json["default_image"],
        imagePath: json["image_path"],
        logoImagePath: json["logo_image_path"],
        onboardScreen: List<OnboardScreen>.from(
            json["onboard_screen"].map((x) => OnboardScreen.fromJson(x))),
        splashScreen: SplashScreen.fromJson(json["splash_screen"]),
      );

  Map<String, dynamic> toJson() => {
        "all_logo": allLogo.toJson(),
        "app_url": appUrl.toJson(),
        "default_image": defaultImage,
        "image_path": imagePath,
        "logo_image_path": logoImagePath,
        "onboard_screen":
            List<dynamic>.from(onboardScreen.map((x) => x.toJson())),
        "splash_screen": splashScreen.toJson(),
      };
}

class AllLogo {
  String siteFav;
  String siteFavDark;
  String siteLogo;
  String siteLogoDark;

  AllLogo({
    required this.siteFav,
    required this.siteFavDark,
    required this.siteLogo,
    required this.siteLogoDark,
  });

  factory AllLogo.fromJson(Map<String, dynamic> json) => AllLogo(
        siteFav: json["site_fav"],
        siteFavDark: json["site_fav_dark"],
        siteLogo: json["site_logo"],
        siteLogoDark: json["site_logo_dark"],
      );

  Map<String, dynamic> toJson() => {
        "site_fav": siteFav,
        "site_fav_dark": siteFavDark,
        "site_logo": siteLogo,
        "site_logo_dark": siteLogoDark,
      };
}

class AppUrl {
  String androidUrl;
  DateTime createdAt;
  int id;
  String isoUrl;
  DateTime updatedAt;

  AppUrl({
    required this.androidUrl,
    required this.createdAt,
    required this.id,
    required this.isoUrl,
    required this.updatedAt,
  });

  factory AppUrl.fromJson(Map<String, dynamic> json) => AppUrl(
        androidUrl: json["android_url"],
        createdAt: DateTime.parse(json["created_at"]),
        id: json["id"],
        isoUrl: json["iso_url"],
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "android_url": androidUrl,
        "created_at": createdAt.toIso8601String(),
        "id": id,
        "iso_url": isoUrl,
        "updated_at": updatedAt.toIso8601String(),
      };
}

class OnboardScreen {
  DateTime createdAt;
  int id;
  String image;
  int status;
  String subTitle;
  String title;
  DateTime updatedAt;

  OnboardScreen({
    required this.createdAt,
    required this.id,
    required this.image,
    required this.status,
    required this.subTitle,
    required this.title,
    required this.updatedAt,
  });

  factory OnboardScreen.fromJson(Map<String, dynamic> json) => OnboardScreen(
        createdAt: DateTime.parse(json["created_at"]),
        id: json["id"],
        image: json["image"],
        status: json["status"],
        subTitle: json["sub_title"],
        title: json["title"],
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "created_at": createdAt.toIso8601String(),
        "id": id,
        "image": image,
        "status": status,
        "sub_title": subTitle,
        "title": title,
        "updated_at": updatedAt.toIso8601String(),
      };
}

class SplashScreen {
  DateTime createdAt;
  int id;
  String splashScreenImage;
  DateTime updatedAt;
  String version;

  SplashScreen({
    required this.createdAt,
    required this.id,
    required this.splashScreenImage,
    required this.updatedAt,
    required this.version,
  });

  factory SplashScreen.fromJson(Map<String, dynamic> json) => SplashScreen(
        createdAt: DateTime.parse(json["created_at"]),
        id: json["id"],
        splashScreenImage: json["splash_screen_image"],
        updatedAt: DateTime.parse(json["updated_at"]),
        version: json["version"],
      );

  Map<String, dynamic> toJson() => {
        "created_at": createdAt.toIso8601String(),
        "id": id,
        "splash_screen_image": splashScreenImage,
        "updated_at": updatedAt.toIso8601String(),
        "version": version,
      };
}

class Message {
  List<String> success;

  Message({
    required this.success,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        success: List<String>.from(json["success"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "success": List<dynamic>.from(success.map((x) => x)),
      };
}
