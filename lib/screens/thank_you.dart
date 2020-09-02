import 'package:blood_app_nepal/screens/login_screen.dart';
import 'package:flutter/material.dart';

class ThankYou extends StatelessWidget {

  final Scaffold authScreen;

  ThankYou(this.authScreen);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,

      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Thank You for Being a Donor! You are a REAL HERO!!", style: TextStyle(color: Colors.white, fontFamily: "Gotham", fontSize: 26.0),),
              ),
              FlatButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>authScreen));
                },
                color: Colors.blueGrey,
                child: Text("Go Back", style: TextStyle(color: Colors.white, fontFamily: "Gotham", fontSize: 20.0),),
              )
            ],
          ),
        ),
    );
  }
}
