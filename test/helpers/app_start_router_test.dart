import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Settings/helper/app_start_router.dart';
import 'package:everqpidapp/Settings/utils/p_pages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    LoggedInUser.accessToken = null;
  });

  test('login destination when not authenticated', () {
    LoggedInUser.accessToken = null;
    expect(AppStartRouter.isAuthenticated, isFalse);
    expect(
      AppStartRouter.isAuthenticated
          ? AppStartRouter.homeRoute
          : AppStartRouter.loginRoute,
      PPages.welcomePageUi,
    );
  });

  test('home destination when authenticated', () {
    LoggedInUser.accessToken = 'test-token';
    expect(AppStartRouter.isAuthenticated, isTrue);
    expect(
      AppStartRouter.isAuthenticated
          ? AppStartRouter.homeRoute
          : AppStartRouter.loginRoute,
      PPages.mainScreen,
    );
  });
}
