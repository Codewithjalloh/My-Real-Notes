import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();
    test("Should not be initialise to begin with", () {
      expect(provider.isInitialised, false);
    });

    test("cannot log out if not initialised", () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitialisedException>()),
      );
    });

    test("should be able to initialised", () async {
      await provider.initialise();
      expect(provider.isInitialised, true);
    });

    test("User should be null after initialization", () {
      expect(provider.currentUser, null);
    });

    test(
      "should be able to initilised in less than 2 secons",
      () async {
        await provider.initialise();
        expect(provider.isInitialised, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    // test("Create user should delegate to login function", () async {
    //   final badEmailUser = provider.createUser(
    //     email: "foo@bar.com",
    //     password: "anypassword",
    //   );
    //   expect(badEmailUser,
    //       throwsA(const TypeMatcher<UserNotFoundAuthException>()));

    //   final badPasswordUser = provider.createUser(
    //     email: "someone@bar.com",
    //     password: "foobar",
    //   );
    //   expect(badPasswordUser,
    //       throwsA(const TypeMatcher<UserNotFoundAuthException>()));

    //   final user = await provider.createUser(
    //     email: "foo",
    //     password: "bar",
    //   );
    //   expect(provider.currentUser, user);
    //   expect(user.isEmailVerified, false);
    // });

    // test("Logged in user should be able to get verified", () {
    //   provider.sendEmailVerification();
    //   final user = provider.currentUser;
    //   expect(user, isNotNull);
    //   expect(user!.isEmailVerified, true);
    // });

    // test("should be able to log out and log in again", () async {
    //   await provider.logOut();
    //   await provider.logIn(
    //     email: "email",
    //     password: "password",
    //   );
    //   final user = provider.currentUser;
    //   expect(user, isNotNull);
    // });
  });
}

class NotInitialisedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _initialised = false;
  bool get isInitialised => _initialised;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialised) throw NotInitialisedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialise() async {
    await Future.delayed(const Duration(seconds: 1));
    _initialised = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialised) throw NotInitialisedException();
    if (email == "foobar.com") throw UserNotFoundAuthException();
    if (password == "foobar") throw WrongPasswordAuthException();

    const user = AuthUser(isEmailVerified: false, email: '');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialised) throw NotInitialisedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
    throw UnimplementedError();
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialised) throw NotInitialisedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true, email: '');
    _user = newUser;
  }
}
