import 'package:app_luyen_de_thpt/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app_luyen_de_thpt/screens/createtestscreens.dart';
import 'package:app_luyen_de_thpt/screens/loginscreens.dart';
import 'package:app_luyen_de_thpt/utils/Colors.dart';
import 'package:app_luyen_de_thpt/widget/drawerwidget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Settingscreens extends StatefulWidget {
  final AppUser user;
  const Settingscreens({super.key, required this.user});

  @override
  State<Settingscreens> createState() => _SettingscreensState();
}

class _SettingscreensState extends State<Settingscreens> {
  final _auth = FirebaseAuth.instance;

  void _createQuiz() {
    if (_auth.currentUser == null) {
      _navigateToLogin();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionCreationScreen(
          admin: widget.user,
        ),
      ),
    );
  }

  void _checkAuthStatus() {
    if (_auth.currentUser == null) {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _signOut() {
    _auth.signOut();
    _navigateToLogin();
  }

  void _changeLanguage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Tiếng Việt'),
                onTap: () {
                  // Implement language change logic
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('English'),
                onTap: () {
                  // Implement language change logic
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xóa Tài Khoản'),
          content: Text(
              'Bạn có chắc chắn muốn xóa tài khoản? Thao tác này không thể hoàn tác.'),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Xóa Tài Khoản'),
              onPressed: () {
                // Implement account deletion logic
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: mainColor,
        elevation: 4,
      ),
      drawer: Mydrawer(
        onSignoutTap: _signOut,
        onCreateTap: _createQuiz,
        user: widget.user,
      ),
      body: Container(
        color: backgroundColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 8,
                  child: SvgPicture.asset(
                    "assets/icons/personal_settings.svg",
                    height: 350,
                    width: 350,
                  ),
                ),
                _buildSettingsCard(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'Change language app',
                  onTap: _changeLanguage,
                ),
                SizedBox(height: 16),
                _buildSettingsCard(
                  icon: Icons.delete_forever,
                  title: 'Delete account',
                  subtitle: 'Delete your account',
                  onTap: _deleteAccount,
                  color: Colors.red[50],
                  iconColor: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
    Color? iconColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: color ?? Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? mainColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor ?? mainColor,
            size: 30,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
