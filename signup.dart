import 'package:flutter/material.dart';
import 'package:task_manager/signin.dart';
import 'package:task_manager/taskmanager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MySignUp extends StatefulWidget {
  MySignUp({super.key});

  final supabase = Supabase.instance.client;

  Future<void> signUpUser(String email, String password) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user != null) {
      print("SignUp Successfully");
    } else {
      print("SignUp failed");
    }
  }

  @override
  State<MySignUp> createState() => _MySignUpState();
}

class _MySignUpState extends State<MySignUp> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _cpasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Sign Up", style: TextStyle(fontSize: 30))),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                Container(
                  child: TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Name required";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      prefixIconColor: Colors.black,
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Email required";
                      }
                      if (!RegExp(
                        r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                      ).hasMatch(value)) {
                        return "Enter a valid Email Address";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      prefixIconColor: Colors.black,
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,

                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Password required";
                      }
                      if (value.length < 8) {
                        return "Password should have at least 8 characters";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      prefixIconColor: Colors.black,
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: TextFormField(
                    controller: _cpasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Password required";
                      }
                      if (value != _passwordController.text) {
                        return "Enter a valid password";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.password),
                      prefixIconColor: Colors.black,
                      labelText: "Confirm Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    elevation: 10,
                    shadowColor: Colors.black,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text;
                      final name = _nameController.text.trim();

                      try {
                        final response = await Supabase.instance.client.auth
                            .signUp(email: email, password: password);
                        final user = response.user;
                        print("User after signup: $user");

                        if (user != null) {
                          await Supabase.instance.client
                              .from('profiles')
                              .insert({
                                'id': user.id,
                                'email': user.email,
                                'name': name,
                              });

                          print("Profile inserted. Navigating...");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Signup successfully"),
                            ),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyTaskManager(),
                            ),
                          );
                        } else {
                          print("User is null");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Signup failed")),
                          );
                        }
                      } on AuthException catch (e) {
                        print('AuthException: ${e.message}');
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.message)));
                      } catch (e) {
                        print('Unexpected error: $e');
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error occur")));
                      }
                    }
                  },
                  child: Text("SignUp", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?'),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MySignIn()),
                        );
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
