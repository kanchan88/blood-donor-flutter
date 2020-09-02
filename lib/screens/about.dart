import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
      ),
      body: Padding(
        padding: EdgeInsets.all(40.0),
        child: Column(
          children: <Widget>[
            Text(
              "This is the Combined Work of Your Koseli, Dari Gang and MRR for the shake of Happiness!! Yes to Brotherhood, Yes to Humanity. Stay Happy",
              style: TextStyle(fontFamily: "Gotham", fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black)
            ),
            ListTile(
              trailing: Icon(Icons.launch, color: Colors.pinkAccent,),
              title: Text("Your Koseli",  style: TextStyle(fontFamily: "Gotham", fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.pink)),
              onTap: (){
                launch("https://yourkoseli.com");
              },
            )
          ],
        ),
      ),
    );
  }
}
