import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isHidden = true;
  final email_controller = TextEditingController();
  final pwd_controller = TextEditingController();

  signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email_controller.text.trim(),
        password: pwd_controller.text.trim());
  }

  @override
  void dispose() {
    super.dispose();
    email_controller.dispose();
    pwd_controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email_field = TextFormField(
      autofocus: false,
      controller: email_controller,
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        email_controller.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: 'Email',
          prefixIcon: Icon(Icons.email),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );
    var pwd_field = TextFormField(
      controller: pwd_controller,
      obscureText: isHidden,
      decoration: InputDecoration(
        hintText: 'Password',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: isHidden ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
          onPressed: () {
            setState(() {
              isHidden = !isHidden;
            });
          },
        ),
      ),
      keyboardType: TextInputType.visiblePassword,
      autofillHints: [AutofillHints.password],
      validator: (password) => password != null && password.length < 5
          ? 'Enter min. 5 characters'
          : null,
    );

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', scale: 2),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Monitoramento Inteligente de Veículos",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Monitore os veículos de forma prática e eficiente.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Container(
                child: email_field,
                width: MediaQuery.of(context).size.height - 200,
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                child: pwd_field,
                width: MediaQuery.of(context).size.height - 200,
              ),
              const SizedBox(
                height: 30,
              ),
              MaterialButton(
                minWidth: MediaQuery.of(context).size.height - 300,
                height: 60,
                onPressed: signIn,
                color: Colors.indigoAccent[400],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                child: const Text(
                  "Conecte-se",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
