import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:roam_and_report/helpers/states/admin_state.dart';
import 'package:roam_and_report/layout/main_layout.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? error;
  bool? isAdmin;

  @override
  void initState() {
    super.initState();
    _checkCurrentAdmin();
  }

  Future<void> _checkCurrentAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isAdmin = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(user.uid)
        .get();

    setState(() => isAdmin = doc.exists);
  }

  Future<void> _login() async {
    try {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          error = "Please enter both email and password";
        });
        return;
      }

      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

      // Check if user is admin
      final doc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(userCredential.user!.uid)
          .get();

      if (!doc.exists) {
        setState(() {
          error = "You are not an admin";
        });
        await FirebaseAuth.instance.signOut();
        return;
      }

      if (!mounted) return;

      //store admin state in provider
      Provider.of<AdminState>(context, listen: false).setAdmin(true);
      setState(() => isAdmin = true);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = "Please enter a valid email address";
          break;
        case 'user-not-found':
          message = "User not found";
          break;
        case 'wrong-password':
          message = "Invalid email address or password";
          break;
        case 'user-disabled':
          message = "This account has been disabled";
          break;
        case 'too-many-requests':
          message = "Too many attempts. Please try again later";
          break;
        case 'network-request-failed':
          message = "No internet connection";
          break;
        case 'operation-not-allowed':
          message = "Login is not enabled";
          break;
        default:
          message = "Login failed. Please try again";
      }
      setState(() {
        error = message;
      });
    } catch (e) {
      // Any other unexpected error
      setState(() {
        error = "An unexpected error occurred. Please try again.";
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }

    if (!mounted) return;

    _emailController.clear();
    _passwordController.clear();
    error = "";
    Provider.of<AdminState>(context, listen: false).setAdmin(false);
    setState(() => isAdmin = false);
  }

  @override
  Widget build(BuildContext context) {
    //Loading
    if (isAdmin == null) {
      return const MainLayout(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "Admin Login",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    //already logged in as admin
    if (isAdmin == true) {
      return MainLayout(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "Admin login",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  "You are already logged in as an admin",
                  style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signOut,
                child: const Text("Sign Out"),
              ),
            ],
          ),
        ),
      );
    }

    //sign in page
    return MainLayout(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Admin login",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Enter your email address and password if you are a registered admin:",
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("Login")),
            const SizedBox(height: 20),
            if (error != null)
              Text(
                error!,
                style: const TextStyle(fontSize: 15, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
