import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:convert';
import '../models/user_model.dart';
import '../config/backend_config.dart';
import 'wallet_service.dart';

const bool USE_DEVELOPMENT_MODE = false; // Real SMS enabled!

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserModel? _currentUser;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  AuthService() {
    // Listen to authentication state changes
    _auth.authStateChanges().listen((User? user) async {
      try {
        if (user != null) {
          // ensure a wallet exists for every authenticated user
          try {
            await WalletService().ensureWallet(user.uid);
          } catch (_) {
            // silently ignore; wallet support is best-effort
          }

          try {
            final DocumentSnapshot doc =
                await _firestore.collection('users').doc(user.uid).get();

            if (doc.exists) {
              final data = doc.data() as Map<String, dynamic>;
              _currentUser = UserModel(
                id: user.uid,
                name: data['name'] ?? user.displayName ?? 'User',
                email: user.email ?? '',
                role: data['role'] ?? 'customer',
                status: data['status'] ?? 'Active',
                avatarUrl: data['avatarUrl'],
                permissions: List<String>.from(data['permissions'] ?? []),
                phoneNumber: data['phoneNumber'],
                isTwoFactorEnabled: data['isTwoFactorEnabled'] ?? false,
              );

              // Force logout if account is suspended or deleted
              if (_currentUser!.status == 'Suspended' ||
                  _currentUser!.status == 'Deleted') {
                await _auth.signOut();
                _currentUser = null;
                _isAuthenticated = false;
              }
            } else {
              // Firestore doc doesn't exist yet — build a minimal user from
              // Firebase Auth data so the app doesn't fall back to Guest.
              _currentUser = UserModel(
                id: user.uid,
                name: user.displayName ?? 'User',
                email: user.email ?? '',
                role: 'customer',
                status: 'Active',
              );
            }
          } catch (firestoreError) {
            // Firestore read failed (rules, network, etc.).
            // Schedule a retry in 3 seconds so a transient failure doesn't
            // permanently lock the user into a wrong role.
            debugPrint('AuthService: Firestore user doc read failed: $firestoreError — will retry in 3 s');
            Future.delayed(const Duration(seconds: 3), () async {
              try {
                final retryDoc = await _firestore.collection('users').doc(user.uid).get();
                if (retryDoc.exists) {
                  final data = retryDoc.data() as Map<String, dynamic>;
                  _currentUser = UserModel(
                    id: user.uid,
                    name: data['name'] ?? user.displayName ?? 'User',
                    email: user.email ?? '',
                    role: data['role'] ?? 'customer',
                    status: data['status'] ?? 'Active',
                    avatarUrl: data['avatarUrl'],
                    permissions: List<String>.from(data['permissions'] ?? []),
                    phoneNumber: data['phoneNumber'],
                    isTwoFactorEnabled: data['isTwoFactorEnabled'] ?? false,
                  );
                  _isAuthenticated = true;
                  notifyListeners();
                }
              } catch (_) {
                // Retry also failed — leave current state as-is
              }
            });
            // In the meantime, show a minimal user using Firebase Auth data.
            // Keep existing _currentUser if we already had one (e.g. from a
            // previous successful read), otherwise build a bare minimum.
            _currentUser ??= UserModel(
              id: user.uid,
              name: user.displayName ?? user.email?.split('@').first ?? 'User',
              email: user.email ?? '',
              role: 'customer', // will be corrected by retry
              status: 'Active',
            );
          }

          _isAuthenticated = _currentUser != null;
        } else {
          _currentUser = null;
          _isAuthenticated = false;
        }
      } catch (e) {
        debugPrint('AuthService: authStateChanges listener error: $e');
      } finally {
        // Always notify — even on error — so the UI never stays frozen on
        // "Guest User" due to a silently-dying async callback.
        notifyListeners();
      }
    });
  }

  // --- Firebase MFA Enrollment Helpers ---
  // Start phone verification to enroll the current logged-in user as a
  // second factor. Returns the verificationId via onCodeSent.
  Future<void> startEnrollPhone(
    String phoneNumber, {
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-complete: attempt to link immediately
          try {
            final user = _auth.currentUser;
            if (user != null) {
              await user.linkWithCredential(credential);
              // update Firestore phone and 2FA flag
              await _firestore.collection('users').doc(user.uid).update({
                'phoneNumber': phoneNumber,
                'isTwoFactorEnabled': true,
              });
            }
          } catch (e) {
            debugPrint('Auto-link on enroll failed: $e');
          }
        },
              verificationFailed: (FirebaseAuthException e) {
                debugPrint('Enroll verification failed: $e');
                if (e.code == 'billing-not-enabled') {
                  onError('Firebase Phone Auth requires enabling reCAPTCHA Enterprise billing on the project. Enable billing and the reCAPTCHA Enterprise API in Google Cloud Console, or add test phone numbers in Firebase Console for development.');
                } else {
                  onError(e.message ?? 'Verification failed');
                }
        },
        codeSent: (String verificationId, int? resendToken) {
          _currentVerificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _currentVerificationId = verificationId;
        },
      );
    } catch (e) {
      debugPrint('startEnrollPhone error: $e');
      onError(e.toString());
    }
  }

  // Confirm enrollment with the SMS code (link phone credential to user)
  Future<String?> confirmEnrollPhone(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      final user = _auth.currentUser;
      if (user == null) return 'No authenticated user to enroll';

      await user.linkWithCredential(credential);
      // Persist phone and 2FA flag in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'phoneNumber': user.phoneNumber ?? _currentPhoneNumber,
        'isTwoFactorEnabled': true,
      });
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('confirmEnrollPhone error: ${e.message}');
      return e.message ?? 'Enrollment failed';
    } catch (e) {
      debugPrint('confirmEnrollPhone error: $e');
      return 'Enrollment failed';
    }
  }

  // Returns null on success, 'requires_2fa' when 2FA OTP must be verified,
  // or an error message string.
  Future<String?> login(String email, String password) async {
    // DEVELOPER BYPASS: Allow login with specific credentials for testing
    if (email == 'admin@dipstore.com' && password == 'password') {
      _currentUser = const UserModel(
        id: 'mock_admin',
        name: 'Admin User',
        email: 'admin@dipstore.com',
        role: 'Superadmin',
        permissions: ['all'],
      );
      _isAuthenticated = true;
      notifyListeners();
      return null; // Success
    }

    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Fetch the user's Firestore document to check status and 2FA.
      // Wrap in its own try-catch so a Firestore failure doesn't block login.
      try {
        final uid = cred.user!.uid;
        final doc = await _firestore.collection('users').doc(uid).get();
        final data = doc.data();

        // Block suspended / deleted accounts before navigating to the shell
        final status = data?['status'] as String?;
        if (status == 'Suspended') {
          await _auth.signOut();
          return 'Your account has been suspended. Please contact support.';
        }
        if (status == 'Deleted') {
          await _auth.signOut();
          return 'This account no longer exists.';
        }

        final twoFaEnabled = data?['isTwoFactorEnabled'] == true;
        final phone = data?['phoneNumber'] as String?;

        if (twoFaEnabled && phone != null && phone.isNotEmpty) {
          // Sign the Firebase user back out until 2FA is verified
          await _auth.signOut();
          // Store credentials temporarily so the OTP screen can complete login
          _pending2faEmail = email;
          _pending2faPassword = password;
          _pending2faPhone = phone;
          _pending2faUid = uid;
          return 'requires_2fa';
        }

        // Set _currentUser immediately so the shell sees the correct role
        // (including Superadmin) the moment we navigate — don't wait for
        // the async authStateChanges listener to finish.
        _currentUser = UserModel(
          id: uid,
          name: data?['name'] as String? ?? cred.user!.displayName ?? 'User',
          email: cred.user!.email ?? '',
          role: data?['role'] as String? ?? 'customer',
          status: data?['status'] as String? ?? 'Active',
          avatarUrl: data?['avatarUrl'] as String?,
          permissions: List<String>.from(data?['permissions'] ?? []),
          phoneNumber: data?['phoneNumber'] as String?,
          isTwoFactorEnabled: data?['isTwoFactorEnabled'] == true,
        );
        _isAuthenticated = true;
        notifyListeners();
      } catch (firestoreError) {
        // Firestore check failed — proceed with normal login rather than
        // blocking the user who has valid credentials.
        debugPrint("Firestore pre-login check failed (non-fatal): $firestoreError");
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      debugPrint("Login error: ${e.message}");
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return e.message ?? 'An unknown error occurred.';
      }
    } catch (e) {
      debugPrint("Login error: $e");
      return "Connection failed. Please check your internet and try again.";
    }
  }

  // Pending 2FA state
  String? _pending2faEmail;
  String? _pending2faPassword;
  String? _pending2faPhone;

  String? get pending2faPhone => _pending2faPhone;

  // Called from OTP screen after user confirms the 2FA code
  Future<String?> completeLoginAfter2fa() async {
    if (_pending2faEmail == null || _pending2faPassword == null) {
      return 'Session expired. Please log in again.';
    }
    try {
      await _auth.signInWithEmailAndPassword(
        email: _pending2faEmail!,
        password: _pending2faPassword!,
      );
      _pending2faEmail = null;
      _pending2faPassword = null;
      _pending2faPhone = null;
      _pending2faUid = null;
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed';
    } catch (e) {
      return 'Login failed';
    }
  }

  // Toggle 2FA for the current user
  Future<void> setTwoFactorEnabled(bool enabled) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .update({'isTwoFactorEnabled': enabled});
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        role: _currentUser!.role,
        status: _currentUser!.status,
        phoneNumber: _currentUser!.phoneNumber,
        avatarUrl: _currentUser!.avatarUrl,
        permissions: _currentUser!.permissions,
        shopId: _currentUser!.shopId,
        isTwoFactorEnabled: enabled,
      );
      notifyListeners();
    }
  }

  // Guest login with restricted access
  Future<void> loginAsGuest() async {
    _currentUser = UserModel.guest();
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      // 1. Create Auth User
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 2. Update Display Name
      await cred.user?.updateDisplayName(name);
      
      // 3. Create Firestore Document
      if (cred.user != null) {
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'role': 'customer', // Default role
          'status': 'Active',
          'createdAt': FieldValue.serverTimestamp(),
        });
        // also create a wallet record with zero balance
        await WalletService().ensureWallet(cred.user!.uid);        
        // Force refresh to trigger listener with new data
        await cred.user?.reload();
      }
    } catch (e) {
      debugPrint("Registration error: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // user may not have been signed in with Google; ignore
    }
  }

  // --- Google Sign-In ---
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return 'Sign in cancelled';

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;

      // Create Firestore doc on first sign-in
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        await _firestore.collection('users').doc(uid).set({
          'name': userCredential.user!.displayName ?? googleUser.displayName ?? 'User',
          'email': userCredential.user!.email ?? '',
          'role': 'customer',
          'status': 'Active',
          'avatarUrl': userCredential.user!.photoURL,
          'permissions': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
        await WalletService().ensureWallet(uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Google sign-in failed';
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return 'Google sign-in failed';
    }
  }

  // --- Magic Link (Email Link) ---
  // NOTE: For mobile, configure deep links in AndroidManifest.xml / ios/Runner/Info.plist.
  // The continueUrl must be a domain authorised in Firebase Console → Auth → Authorized domains.
  Future<String?> sendMagicLink(String email) async {
    try {
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://little-wing-v2.firebaseapp.com/email-link-sign-in',
        handleCodeInApp: true,
        androidPackageName: 'com.dipstore.dipstore_ui',
        androidInstallApp: true,
        androidMinimumVersion: '21',
        iOSBundleId: 'com.dipstore.dipstoreUi',
      );
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to send magic link';
    } catch (e) {
      debugPrint('Magic link error: $e');
      return 'Failed to send magic link';
    }
  }

  Future<String?> signInWithEmailLink(
      {required String email, required String emailLink}) async {
    try {
      if (!_auth.isSignInWithEmailLink(emailLink)) {
        return 'Invalid sign-in link';
      }
      final userCredential =
          await _auth.signInWithEmailLink(email: email, emailLink: emailLink);
      final uid = userCredential.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        await _firestore.collection('users').doc(uid).set({
          'name': email.split('@').first,
          'email': email,
          'role': 'customer',
          'status': 'Active',
          'permissions': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
        await WalletService().ensureWallet(uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Magic link sign-in failed';
    } catch (e) {
      debugPrint('Magic link sign-in error: $e');
      return 'Magic link sign-in failed';
    }
  }

  // --- Phone Authentication (Twilio OTP via Secure Backend) ---
  // For production, this should call your Cloud Function or backend server
  // Credentials are stored securely on the server, not in the client app
  // Optionally use Firebase Phone Auth for second-factor (recommended).
  static const bool USE_FIREBASE_PHONE_AUTH = true;

  // Development-only test phone numbers and their fixed OTP codes.
  // Each phone can have multiple accepted test codes. The first code is
  // returned by `sendOtp` for convenience.
  static const Map<String, List<String>> DEV_TEST_PHONE_CODES = {
    '+9647508131992': ['112233', '111111'],
    '+9647759630353': ['112233', '222222'],
  };

  String? _currentPhoneNumber;
  String? _currentOtpCode;
  String? _currentVerificationId;
  String? _pending2faUid;

  Future<void> sendOtp(
    String phoneNumber, {
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    // Quick dev override: accept test numbers with predefined codes.
    if (DEV_TEST_PHONE_CODES.containsKey(phoneNumber)) {
      _currentPhoneNumber = phoneNumber;
      final codes = DEV_TEST_PHONE_CODES[phoneNumber]!;
      _currentOtpCode = codes.isNotEmpty ? codes.first : null;
      debugPrint('Using dev test OTP(s) for $phoneNumber: $codes');
      onCodeSent(_currentOtpCode ?? '');
      return;
    }
    // Prefer Firebase phone auth for second-factor verification when enabled.
    if (USE_FIREBASE_PHONE_AUTH) {
      try {
        _currentPhoneNumber = phoneNumber;
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            try {
              final result = await _auth.signInWithCredential(credential);
              if (_pending2faUid != null && result.user?.uid == _pending2faUid) {
                await _auth.signOut();
              }
            } catch (_) {}
          },
                verificationFailed: (FirebaseAuthException e) {
                  debugPrint('Firebase phone verification failed: $e');
                  if (e.code == 'billing-not-enabled') {
                    onError('Firebase Phone Auth requires enabling reCAPTCHA Enterprise billing on the project. Enable billing and the reCAPTCHA Enterprise API in Google Cloud Console, or add test phone numbers in Firebase Console for development.');
                  } else {
                    onError(e.message ?? 'Phone verification failed');
                  }
          },
          codeSent: (String verificationId, int? resendToken) {
            _currentVerificationId = verificationId;
            debugPrint('Firebase SMS code sent to $phoneNumber (vid=$verificationId)');
            onCodeSent('');
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _currentVerificationId = verificationId;
          },
        );
        return;
      } catch (e) {
        debugPrint('Send OTP Error (firebase): $e');
        onError(e.toString());
        return;
      }
    }

    try {
      // Try calling backend API first
      try {
        final response = await http.post(
          Uri.parse('$backendBaseUrl/api/send-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phoneNumber': phoneNumber}),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Request timeout'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success']) {
            _currentPhoneNumber = phoneNumber;

            // For development mode, backend returns OTP
            if (data['otp'] != null) {
              _currentOtpCode = data['otp'];
              debugPrint("📱 OTP for testing: ${data['otp']}");
            }

            debugPrint("✅ OTP sent to $phoneNumber via SMS");
            onCodeSent((data['otp'] ?? '').toString());
            return;
          }
        }
        final failData = jsonDecode(response.body);
        onError((failData['message'] ?? 'Failed to send OTP').toString());
        return;
      } catch (backendError) {
        debugPrint("⚠️  Backend error: $backendError");
      }

      // Fallback to development mode if backend fails
      if (USE_DEVELOPMENT_MODE) {
        debugPrint("📝 Using development mode (backend not available)");
        _currentPhoneNumber = phoneNumber;
        _currentOtpCode = _generateOtp();

        debugPrint("📱 OTP for testing: $_currentOtpCode");
        debugPrint("⏰ OTP expires in 10 minutes");

        onCodeSent(_currentOtpCode ?? "");
        return;
      }

      onError("Failed to send OTP and development mode is disabled");
    } catch (e) {
      debugPrint("Send OTP Error: $e");
      onError(e.toString());
    }
  }

  Future<bool> verifyOtp(String otp) async {
    try {
      if (_currentPhoneNumber == null) {
        debugPrint("Error: No phone number found");
        return false;
      }

      // Dev test numbers: accept any of the configured test codes locally.
      if (DEV_TEST_PHONE_CODES.containsKey(_currentPhoneNumber)) {
        final accepted = DEV_TEST_PHONE_CODES[_currentPhoneNumber]!;
        if (accepted.contains(otp.trim())) {
          _isAuthenticated = true;
          notifyListeners();
          debugPrint('✅ Dev OTP verified for $_currentPhoneNumber');
          return true;
        } else {
          debugPrint('❌ Dev OTP mismatch for $_currentPhoneNumber');
          return false;
        }
      }

      // If using Firebase phone auth for verification, validate using the
      // stored verificationId and PhoneAuthCredential.
      if (USE_FIREBASE_PHONE_AUTH && _currentVerificationId != null) {
        try {
          final credential = PhoneAuthProvider.credential(
            verificationId: _currentVerificationId!,
            smsCode: otp.trim(),
          );

          // Sign in with the phone credential temporarily to verify ownership
          final result = await _auth.signInWithCredential(credential);
          // If we had a pending 2FA uid, ensure it matches.
          if (_pending2faUid != null && result.user?.uid != _pending2faUid) {
            // Not the same account — fail verification
            await _auth.signOut();
            return false;
          }

          // Verified — sign the phone session out (we'll complete login by
          // re-signing in with email+password via completeLoginAfter2fa)
          await _auth.signOut();
          return true;
        } catch (e) {
          debugPrint('Firebase OTP verification failed: $e');
          return false;
        }
      }

      // Call backend API to verify OTP
      final response = await http.post(
        Uri.parse('$backendBaseUrl/api/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': _currentPhoneNumber,
          'otp': otp.trim(),
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _isAuthenticated = true;
          notifyListeners();
          debugPrint("✅ OTP verified successfully");
          return true;
        } else {
          debugPrint("❌ Verification failed: ${data['message']}");
          return false;
        }
      }
      final failData = jsonDecode(response.body);
      debugPrint("❌ Verification error: ${failData['message'] ?? response.statusCode}");
      return false;
    } catch (e) {
      debugPrint("Verify OTP Error: $e");
      return false;
    }
  }

  String _generateOtp() {
    final random = Random();
    final otp = 100000 + random.nextInt(900000);
    return otp.toString();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint("Password reset error: $e");
      rethrow;
    }
  }

  // --- User Management (Superadmin) ---

  // Stream of all users
  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel(
          id: doc.id,
          name: data['name'] ?? 'Unknown',
          email: data['email'] ?? '',
          role: data['role'] ?? 'customer',
          status: data['status'] ?? 'Active',
          avatarUrl: data['avatarUrl'],
          permissions: List<String>.from(data['permissions'] ?? []),
        );
      }).toList();
    });
  }

  // Update user details (Name, Role, Status, Phone)
  Future<void> updateUserDetails({
    required String uid, 
    String? name, 
    String? role, 
    String? status,
    List<String>? permissions,
    String? phoneNumber,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (role != null) updates['role'] = role;
      if (status != null) updates['status'] = status;
      if (permissions != null) updates['permissions'] = permissions;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      
      await _firestore.collection('users').doc(uid).update(updates);

      // Keep in-memory model in sync if updating the current user
      if (_currentUser != null && _currentUser!.id == uid) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          name: name ?? _currentUser!.name,
          email: _currentUser!.email,
          role: role ?? _currentUser!.role,
          status: status ?? _currentUser!.status,
          avatarUrl: _currentUser!.avatarUrl,
          permissions: permissions ?? _currentUser!.permissions,
          phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
          shopId: _currentUser!.shopId,
          isTwoFactorEnabled: _currentUser!.isTwoFactorEnabled,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating user details: $e");
      rethrow;
    }
  }

  // Delete user (Soft delete by setting status to Deleted)
  Future<void> deleteUser(String uid) async {
    await updateUserDetails(uid: uid, status: 'Deleted');
  }

  // Create user by Admin (using secondary app to avoid logging out)
  Future<void> createUserByAdmin({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    FirebaseApp? tempApp;
    try {
      // 1. Initialize a secondary Firebase App
      tempApp = await Firebase.initializeApp(
        name: 'tempAuthApp',
        options: Firebase.app().options,
      );

      // 2. Create the user in Auth using the secondary app
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
      UserCredential cred = await tempAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. Create the user document in Firestore (using main app instance)
      if (cred.user != null) {
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'name': name,
          'email': email,
          'role': role,
          'status': 'Active',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      // 4. Sign out the temp user immediately from the temp app
      await tempAuth.signOut();

    } catch (e) {
      debugPrint("Error creating user by admin: $e");
      rethrow;
    } finally {
      // 5. Delete the temp app
      await tempApp?.delete();
    }
  }
}
