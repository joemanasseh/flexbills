import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../routes/routes.dart';
import '../../utils/basic_screen_imports.dart';
import '../local_storage/local_storage.dart';
import '../models/common/error_message_model.dart';
import 'custom_snackbar.dart';
import 'logger.dart';

final log = logger(ApiMethod);

Map<String, String> basicHeaderInfo() {
  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
  };
}

Future<Map<String, String>> bearerHeaderInfo() async {
  final String? accessToken = LocalStorage.getToken();
  if (accessToken == null) {
    await LocalStorage.logout();
    Get.offAllNamed(Routes.loginScreen);
    return {};
  }
  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.authorizationHeader: "Bearer $accessToken",
  };
}

void _handleUnauthorized() {
  LocalStorage.logout();
  Get.offAllNamed(Routes.loginScreen);
  CustomSnackBar.error('Session expired. Please log in again.');
}

class ApiMethod {
  ApiMethod({required this.isBasic});

  bool isBasic;

  // Get method
  Future<Map<String, dynamic>?> get(
    String url, {
    int code = 200,
    int duration = 15,
    bool showResult = false,
    bool stream = false,
  }) async {
    if (!stream && kDebugMode) {
      log.i('GET $url');
    }

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));

      if (!stream && kDebugMode) {
        log.i('GET ${response.statusCode}');
        if (showResult) log.i(response.body);
      }

      if (response.statusCode == 401) {
        _handleUnauthorized();
        return null;
      }
      if (response.statusCode == 403) {
        if (!stream) CustomSnackBar.error('You do not have permission to access this resource.');
        return null;
      }
      if (response.statusCode == 404) {
        log.i('404 $url — endpoint not found, skipping.');
        return null;
      }

      if (response.statusCode == code) {
        if (response.body.isEmpty) {
          if (!stream) CustomSnackBar.error('Server returned empty response');
          return null;
        }
        return jsonDecode(response.body);
      } else {
        try {
          if (response.body.isNotEmpty) {
            ErrorResponse res = ErrorResponse.fromJson(jsonDecode(response.body));
            if (!stream) CustomSnackBar.error(res.message!.error!.first.toString());
          } else {
            if (!stream) CustomSnackBar.error('Server returned an error');
          }
        } catch (_) {
          if (!stream) CustomSnackBar.error('Server error occurred');
        }
        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');

      if (!stream) {
        CustomSnackBar.error('Check your Internet Connection and try again!');
      }
      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');

      if (!stream) {
        CustomSnackBar.error('Something Went Wrong! Try again');
      }
      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } on FormatException catch (e) {
      log.e('🐞🐞🐞 Error Alert FormatException 🐞🐞🐞');

      log.e('Invalid JSON response: $e');

      if (!stream) {
        CustomSnackBar.error('Invalid server response format');
      }

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  // Post Method
  Future<Map<String, dynamic>?> post(String url, Map<String, dynamic> body,
      {int code = 200, int duration = 30, bool showResult = false}) async {
    try {
      if (kDebugMode) log.i('POST $url');

      final response = await http
          .post(
            Uri.parse(url),
            body: jsonEncode(body),
            headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));

      if (kDebugMode) {
        log.i('POST ${response.statusCode}');
        if (showResult) log.i(response.body);
      }

      if (response.statusCode == 401) {
        _handleUnauthorized();
        return null;
      }
      if (response.statusCode == 403) {
        // 403 = the account lacks permission for this resource.
        // Do NOT logout — the token is still valid. Just surface an error.
        CustomSnackBar.error('You do not have permission to access this resource.');
        return null;
      }
      if (response.statusCode == 404) {
        // 404 = endpoint not implemented on this server / not available for
        // this account. Return null silently — the server's raw error body
        // (e.g. "Unable to connect to API") would be confusing to the user.
        log.w('404 on $url — endpoint not found, ignoring.');
        return null;
      }

      if (response.statusCode == code) {
        if (response.body.isEmpty) {
          CustomSnackBar.error('Server returned empty response');
          return null;
        }
        return jsonDecode(response.body);
      } else {
        try {
          if (response.body.isNotEmpty) {
            ErrorResponse res = ErrorResponse.fromJson(jsonDecode(response.body));
            CustomSnackBar.error(res.message!.error!.first.toString());
          } else {
            CustomSnackBar.error('Server returned an error');
          }
        } catch (_) {
          CustomSnackBar.error('Server error occurred');
        }
        return null;
      }
    } on SocketException {
      CustomSnackBar.error('Check your Internet Connection and try again!');
      return null;
    } on TimeoutException {
      CustomSnackBar.error('Something Went Wrong! Try again');
      return null;
    } on http.ClientException {
      return null;
    } on FormatException {
      CustomSnackBar.error('Invalid server response format');
      return null;
    } catch (e) {
      log.e(e);
      return null;
    }
  }

  // Param get method
  Future<Map<String, dynamic>?> paramGet(String url, Map<String, String> body,
      {int code = 200, int duration = 15, bool showResult = false}) async {
    if (kDebugMode) log.i('PARAM GET $url');

    try {
      final response = await http
          .get(
            Uri.parse(url).replace(queryParameters: body),
            headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));

      if (kDebugMode) {
        log.i('PARAM GET ${response.statusCode}');
        if (showResult) log.i(response.body);
      }

      if (response.statusCode == 401) {
        _handleUnauthorized();
        return null;
      }
      if (response.statusCode == 403) {
        // 403 = the account lacks permission for this resource.
        // Do NOT logout — the token is still valid. Just surface an error.
        CustomSnackBar.error('You do not have permission to access this resource.');
        return null;
      }
      if (response.statusCode == 404) {
        // 404 = endpoint not implemented on this server / not available for
        // this account. Return null silently — the server's raw error body
        // (e.g. "Unable to connect to API") would be confusing to the user.
        log.w('404 on $url — endpoint not found, ignoring.');
        return null;
      }

      if (response.statusCode == code) {
        return jsonDecode(response.body);
      } else {
        try {
          ErrorResponse res = ErrorResponse.fromJson(jsonDecode(response.body));
          CustomSnackBar.error(res.message!.error!.first.toString());
        } catch (_) {
          CustomSnackBar.error('Server error occurred');
        }
        return null;
      }
    } on SocketException {
      CustomSnackBar.error('Check your Internet Connection and try again!');
      return null;
    } on TimeoutException {
      CustomSnackBar.error('Something Went Wrong! Try again');
      return null;
    } on http.ClientException {
      return null;
    } catch (e) {
      log.e(e);
      return null;
    }
  }

  // Multipart single file
  Future<Map<String, dynamic>?> multipart(
      String url, Map<String, String> body, String filepath, String filedName,
      {int code = 200, bool showResult = false}) async {
    if (kDebugMode) log.i('MULTIPART POST $url');
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields.addAll(body)
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer ${LocalStorage.getToken() ?? ""}'
        })
        ..files.add(await http.MultipartFile.fromPath(filedName, filepath));
      final response = await request.send();
      final jsonData = await http.Response.fromStream(response);

      if (kDebugMode) {
        log.i('MULTIPART POST ${response.statusCode}');
        if (showResult) log.i(jsonData.body);
      }

      if (response.statusCode == 401) {
        _handleUnauthorized();
        return null;
      }
      if (response.statusCode == 403) {
        // 403 = the account lacks permission for this resource.
        // Do NOT logout — the token is still valid. Just surface an error.
        CustomSnackBar.error('You do not have permission to access this resource.');
        return null;
      }
      if (response.statusCode == 404) {
        // 404 = endpoint not implemented on this server / not available for
        // this account. Return null silently — the server's raw error body
        // (e.g. "Unable to connect to API") would be confusing to the user.
        log.w('404 on $url — endpoint not found, ignoring.');
        return null;
      }
      if (response.statusCode == code) {
        return jsonDecode(jsonData.body) as Map<String, dynamic>;
      } else {
        try {
          ErrorResponse res = ErrorResponse.fromJson(jsonDecode(jsonData.body));
          CustomSnackBar.error(res.message!.error!.first.toString());
        } catch (_) {
          CustomSnackBar.error('Server error occurred');
        }
        return null;
      }
    } on SocketException {
      CustomSnackBar.error('Check your Internet Connection and try again!');
      return null;
    } on TimeoutException {
      CustomSnackBar.error('Something Went Wrong! Try again');
      return null;
    } on http.ClientException {
      return null;
    } catch (e) {
      log.e(e);
      return null;
    }
  }

  // Multipart multiple files
  Future<Map<String, dynamic>?> multipartMultiFile(
    String url,
    Map<String, String> body, {
    int code = 200,
    bool showResult = false,
    required List<String> pathList,
    required List<String> fieldList,
  }) async {
    if (kDebugMode) log.i('MULTIPART MULTI POST $url');
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields.addAll(body)
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer ${LocalStorage.getToken() ?? ""}'
        });
      for (int i = 0; i < fieldList.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(fieldList[i], pathList[i]));
      }
      final response = await request.send();
      final jsonData = await http.Response.fromStream(response);

      if (kDebugMode) {
        log.i('MULTIPART MULTI POST ${response.statusCode}');
        if (showResult) log.i(jsonData.body);
      }

      if (response.statusCode == 401) {
        _handleUnauthorized();
        return null;
      }
      if (response.statusCode == 403) {
        // 403 = the account lacks permission for this resource.
        // Do NOT logout — the token is still valid. Just surface an error.
        CustomSnackBar.error('You do not have permission to access this resource.');
        return null;
      }
      if (response.statusCode == 404) {
        // 404 = endpoint not implemented on this server / not available for
        // this account. Return null silently — the server's raw error body
        // (e.g. "Unable to connect to API") would be confusing to the user.
        log.w('404 on $url — endpoint not found, ignoring.');
        return null;
      }
      if (response.statusCode == code) {
        return jsonDecode(jsonData.body) as Map<String, dynamic>;
      } else {
        try {
          ErrorResponse res = ErrorResponse.fromJson(jsonDecode(jsonData.body));
          CustomSnackBar.error(res.message!.error!.first.toString());
        } catch (_) {
          CustomSnackBar.error('Server error occurred');
        }
        return null;
      }
    } on SocketException {
      CustomSnackBar.error('Check your Internet Connection and try again!');
      return null;
    } on TimeoutException {
      CustomSnackBar.error('Something Went Wrong! Try again');
      return null;
    } on http.ClientException {
      return null;
    } catch (e) {
      log.e(e);
      return null;
    }
  }

  // Delete method
  Future<Map<String, dynamic>?> delete(String url,
      {int code = 202, bool isLogout = false, int duration = 15, bool showResult = false}) async {
    if (kDebugMode) log.i('DELETE $url');
    try {
      final headers = isBasic ? basicHeaderInfo() : await bearerHeaderInfo();
      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(Duration(seconds: duration));

      if (kDebugMode) {
        log.i('DELETE ${response.statusCode}');
        if (showResult) log.i(response.body);
      }

      if (response.statusCode == 401) {
        _handleUnauthorized();
        return null;
      }
      if (response.statusCode == 403) {
        // 403 = the account lacks permission for this resource.
        // Do NOT logout — the token is still valid. Just surface an error.
        CustomSnackBar.error('You do not have permission to access this resource.');
        return null;
      }
      if (response.statusCode == 404) {
        // 404 = endpoint not implemented on this server / not available for
        // this account. Return null silently — the server's raw error body
        // (e.g. "Unable to connect to API") would be confusing to the user.
        log.w('404 on $url — endpoint not found, ignoring.');
        return null;
      }
      if (response.statusCode == code) {
        return jsonDecode(response.body);
      } else {
        try {
          ErrorResponse res = ErrorResponse.fromJson(jsonDecode(response.body));
          CustomSnackBar.error(res.message!.error!.first.toString());
        } catch (_) {
          CustomSnackBar.error('Server error occurred');
        }
        return null;
      }
    } on SocketException {
      CustomSnackBar.error('Check your Internet Connection and try again!');
      return null;
    } on TimeoutException {
      CustomSnackBar.error('Something Went Wrong! Try again');
      return null;
    } on http.ClientException {
      return null;
    } catch (e) {
      log.e(e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> put(String url, Map<String, String> body,
      {int code = 202, int duration = 15, bool showResult = false}) async {
    if (kDebugMode) log.i('PUT $url');
    try {
      final response = await http
          .put(Uri.parse(url), body: jsonEncode(body),
              headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo())
          .timeout(Duration(seconds: duration));

      if (kDebugMode) {
        log.i('PUT ${response.statusCode}');
        if (showResult) log.i(response.body);
      }

      if (response.statusCode == 401) {
        _handleUnauthorized();
        return null;
      }
      if (response.statusCode == 403) {
        // 403 = the account lacks permission for this resource.
        // Do NOT logout — the token is still valid. Just surface an error.
        CustomSnackBar.error('You do not have permission to access this resource.');
        return null;
      }
      if (response.statusCode == 404) {
        // 404 = endpoint not implemented on this server / not available for
        // this account. Return null silently — the server's raw error body
        // (e.g. "Unable to connect to API") would be confusing to the user.
        log.w('404 on $url — endpoint not found, ignoring.');
        return null;
      }
      if (response.statusCode == code) {
        return jsonDecode(response.body);
      } else {
        try {
          ErrorResponse res = ErrorResponse.fromJson(jsonDecode(response.body));
          CustomSnackBar.error(res.message!.error!.first.toString());
        } catch (_) {
          CustomSnackBar.error('Server error occurred');
        }
        return null;
      }
    } on SocketException {
      CustomSnackBar.error('Check your Internet Connection and try again!');
      return null;
    } on TimeoutException {
      CustomSnackBar.error('Request Timed out! Try again');
      return null;
    } on http.ClientException {
      return null;
    } catch (e) {
      log.e(e);
      return null;
    }
  }

  // Multipart for conversation
  Future<Map<String, dynamic>?> multipart2(
      String url, Map<String, String> body, String filepath, String filedName,
      {int code = 200, bool showResult = false}) async {
    if (kDebugMode) log.i('MULTIPART2 POST $url');
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields.addAll(body)
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer ${LocalStorage.getToken() ?? ""}'
        })
        ..files.add(await http.MultipartFile.fromPath(filedName, filepath));
      final response = await request.send();
      final jsonData = await http.Response.fromStream(response);

      if (kDebugMode) {
        log.i('MULTIPART2 POST ${response.statusCode}');
        if (showResult) log.i(jsonData.body);
      }

      if (response.statusCode == 401) {
        _handleUnauthorized();
        return null;
      }
      if (response.statusCode == 403) {
        // 403 = the account lacks permission for this resource.
        // Do NOT logout — the token is still valid. Just surface an error.
        CustomSnackBar.error('You do not have permission to access this resource.');
        return null;
      }
      if (response.statusCode == 404) {
        // 404 = endpoint not implemented on this server / not available for
        // this account. Return null silently — the server's raw error body
        // (e.g. "Unable to connect to API") would be confusing to the user.
        log.w('404 on $url — endpoint not found, ignoring.');
        return null;
      }
      if (response.statusCode == code) {
        return jsonDecode(jsonData.body) as Map<String, dynamic>;
      } else {
        try {
          final error = jsonDecode(jsonData.body)["message"]["error"]["files.0"]?.first;
          CustomSnackBar.error(error ?? 'Server error occurred');
        } catch (_) {
          CustomSnackBar.error('Server error occurred');
        }
        return null;
      }
    } on SocketException {
      CustomSnackBar.error('Check your Internet Connection and try again!');
      return null;
    } on TimeoutException {
      CustomSnackBar.error('Something Went Wrong! Try again');
      return null;
    } on http.ClientException {
      return null;
    } catch (e) {
      log.e(e);
      return null;
    }
  }
}
