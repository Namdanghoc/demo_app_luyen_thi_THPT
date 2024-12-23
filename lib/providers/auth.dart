import 'package:app_luyen_de_thpt/widget/alertDiaLogThongBao.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class AppUser {
  String? id;
  String? email;
  final bool isAdmin;
  String? realname;
  String? namehighschool;
  String? group;
  String? gender;
  String? avatarUrl;
  DateTime? dateOfBirth;

  AppUser({
    this.id,
    this.email,
    this.isAdmin = false,
    this.realname,
    this.namehighschool,
    this.group,
    this.gender,
    this.avatarUrl,
    this.dateOfBirth,
  });

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, isAdmin: $isAdmin, realname: $realname, namehighschool: $namehighschool, dateOfBirth: $dateOfBirth)';
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final storageRefUser = FirebaseStorage.instance.ref();

  Future<AppUser?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String userId = result.user!.uid;
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('User document does not exist for UID: $userId');
        return null;
      }
      Map<String, dynamic>? userData = userDoc.data();

      return AppUser(
          id: userId,
          email: email,
          isAdmin: userData?['isAdmin'] ?? false,
          realname: userData?['realname'],
          namehighschool: userData?['namehighschool'],
          group: userData?['group'],
          gender: userData?['gender'],
          dateOfBirth: (userData?['dateofbirth'] as Timestamp?)?.toDate(),
          avatarUrl: userData?['avatarUrl']);
    } catch (e) {
      print('Sign In Error: $e');
      return null;
    }
  }

  Future<AppUser?> registerUser(
      {required String email,
      required String password,
      required String realname,
      required String namehighschool,
      required DateTime dateOfBirth,
      bool isAdmin = false}) async {
    try {
      if (!_isValidEmail(email)) {
        print('Invalid email format');
        return null;
      }

      if (password.length < 6) {
        print('Password must be at least 6 characters long');
        return null;
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (result.user == null) {
        print('User creation failed');
        return null;
      }

      Map<String, dynamic> userData = {
        'email': email,
        'realname': realname,
        'namehighschool': namehighschool,
        'dateofbirth': Timestamp.fromDate(dateOfBirth),
        'isAdmin': isAdmin,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(result.user!.uid).set(userData);

      return AppUser(
        id: result.user!.uid,
        email: email,
        isAdmin: isAdmin,
        realname: realname,
        namehighschool: namehighschool,
        dateOfBirth: dateOfBirth,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          print('The email address is already in use.');
          AlertDiaLogThongBao(
              tieuDeThongBao: 'Lỗi',
              noiDungThongBao: 'Email đã được sử dụng!');
          break;
        case 'invalid-email':
          print('The email address is not valid.');
          AlertDiaLogThongBao(
              tieuDeThongBao: 'Lỗi',
              noiDungThongBao: 'Email không tồn tại!');
          break;
        case 'operation-not-allowed':
          print('Email/password accounts are not enabled.');
          AlertDiaLogThongBao(
              tieuDeThongBao: 'Lỗi',
              noiDungThongBao: 'Email/password accounts are not enabled!');
          break;
        case 'weak-password':
          print('The password is too weak.');
          AlertDiaLogThongBao(
              tieuDeThongBao: 'Lỗi', noiDungThongBao: 'Mật khẩu quá yếu!');
          break;
        default:
          print('An undefined Error happened: ${e.code}');
          AlertDiaLogThongBao(
              tieuDeThongBao: 'Lỗi',
              noiDungThongBao: 'An undefined Error happened!');
      }
      return null;
    } catch (e) {
      print('Unexpected registration error: $e');
      return null;
    }
  }

  Future<String> uploadAvatar(File imageFile, String userId) async {
    try {
      final storageRef = storageRefUser.child('avatars/$userId.jpg');
      final uploadTask = await storageRef.putFile(imageFile);

      final imageUrl = await storageRef.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      throw e;
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
}
