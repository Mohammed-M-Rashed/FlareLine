import 'package:get/get.dart';
import 'package:flareline/core/models/auth_model.dart';

class AuthController extends GetxController {
  final _isAuthenticated = false.obs;
  final _userEmail = RxString('');
  final _userToken = RxString('');
  final _userData = Rx<AuthUserModel?>(null);

  bool get isAuthenticated => _isAuthenticated.value;
  String get userEmail => _userEmail.value;
  String get userToken => _userToken.value;
  AuthUserModel? get userData => _userData.value;

  void signIn(String email, {String? token, AuthUserModel? user}) {
    _isAuthenticated.value = true;
    _userEmail.value = email;
    if (token != null) {
      _userToken.value = token;
    }
    if (user != null) {
      _userData.value = user;
    }
  }

  void updateToken(String newToken) {
    _userToken.value = newToken;
  }

  void updateUser(AuthUserModel user) {
    _userData.value = user;
  }

  void signOut() {
    _isAuthenticated.value = false;
    _userEmail.value = '';
    _userToken.value = '';
    _userData.value = null;
  }

  bool isLoggedIn() {
    return _isAuthenticated.value;
  }

  bool hasValidToken() {
    return _userToken.value.isNotEmpty;
  }

  String? getAuthorizationHeader() {
    if (_userToken.value.isNotEmpty) {
      return 'Bearer ${_userToken.value}';
    }
    return null;
  }
}
