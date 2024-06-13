import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _email = "";
  var _password = "";
  var logger = Logger();
  var _username = "";
  bool _isLogin = true;
  bool _isLoading = false;
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    submitForm(String email, String password, String username) async {
      final auth = FirebaseAuth.instance;
      UserCredential authResult;
      try {
        setState(() {
          _isLoading = true;
        });
        if (_isLogin) {
          authResult = await auth.signInWithEmailAndPassword(
              email: email, password: password);
        } else {
          authResult = await auth.createUserWithEmailAndPassword(
              email: email, password: password);
          String uid = authResult.user!.uid;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set({'username': username, 'email': email}).then((_) {
            logger.i("User data added to Firestore successfully");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Registered sucessfully")),
            );
          }).catchError((error) {
            logger.e("Failed to add user data to Firestore: $error");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to add user data: $error")),
            );
          });
        }
      } catch (e) {
        logger.d("Exception : $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

    startAuthentication() async {
      final isValid = _formKey.currentState!.validate();
      FocusScope.of(context).unfocus();
      if (isValid) {
        _formKey.currentState!.save();
        submitForm(_email, _password, _username);
      }
    }

    bool validatePassword(String password) {
      String pattern =
          r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
      RegExp regex = RegExp(pattern);
      return regex.hasMatch(password);
    }

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    validator: (email) {
                      final RegExp emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      if (!emailRegex.hasMatch(email!)) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _email = newValue!;
                    },
                    key: const ValueKey('email'),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Enter your email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelStyle: GoogleFonts.roboto(),
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      } else if (!validatePassword(value)) {
                        return 'Password must be at least 8 characters long,\n'
                            'include an uppercase letter, a lowercase letter,\n'
                            'a digit, and a special character';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _password = newValue!;
                    },
                    key: const ValueKey('password'),
                    obscureText: !_isPasswordVisible,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !(_isPasswordVisible);
                            });
                          },
                          icon: Icon(_isPasswordVisible == true
                              ? Icons.visibility
                              : Icons.visibility_off)),
                      labelText: "Password",
                      hintText: "Enter your password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelStyle: GoogleFonts.roboto(),
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  if (!_isLogin)
                    TextFormField(
                      controller: _usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _username = newValue!;
                      },
                      key: const ValueKey('username'),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Username",
                        hintText: "Enter your username",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        labelStyle: GoogleFonts.roboto(),
                      ),
                    ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    height: 60,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        startAuthentication();
                      },
                      style: ElevatedButton.styleFrom(
                        // Text color of the button
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          // Rounded corners
                        ),
                      ),
                      child: Text(
                        _isLogin ? 'Login' : 'Sign Up',
                        style: GoogleFonts.roboto(
                            fontSize: 20.0, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(_isLogin
                          ? "Create new account"
                          : "I already have an account"),
                    ),
                  )
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
