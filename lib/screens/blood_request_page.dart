import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loading.dart';


class ShowRequest extends StatefulWidget {
  @override
  _ShowRequestState createState() => _ShowRequestState();
}

class _ShowRequestState extends State<ShowRequest> {

  final bloodRequestRef = Firestore.instance.collection('request');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blood Requests"),
      ),
      body: StreamBuilder(
        stream: bloodRequestRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularLoading();
          }
          List<ShowRequests> allRequests = [];
          snapshot.data.documents.forEach((doc) {
            allRequests.add(ShowRequests.fromDocument(doc));
          });

          return Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: allRequests,
            ),
          );
        },
      ),
    );
  }
}

class ShowRequests extends StatelessWidget {

  final String location;
  final String bloodGroup;
  final String bloodAmount;
  final String phoneNumber;
  final String requiredDate;

  ShowRequests({
    this.location,
    this.phoneNumber,
    this.bloodGroup,
    this.requiredDate,
    this.bloodAmount,
  });

  factory ShowRequests.fromDocument(DocumentSnapshot doc) {
    return ShowRequests(
      location: doc['location'],
      bloodGroup: doc['bloodGroup'],
      phoneNumber: doc['phoneNumber'],
      requiredDate: doc['bloodNeededDate'],
      bloodAmount: doc['bloodAmount'],
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0)
        ),
        padding: EdgeInsets.only(bottom: 10.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Stack(
                children: <Widget>[
                  Container(
                      height: 120.0,
                      width: 100.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              color: Colors.black87,
                              alignment: Alignment.center,
                              child: Text(location, style: TextStyle(color: Colors.white, )),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child:  Container(
                              alignment: Alignment.center,
                              color: Colors.red,
                              child: Text(bloodGroup, style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      )
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            "Required in $requiredDate",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontFamily: "Gotham",
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Icon(Icons.hdr_strong, color: Colors.redAccent,),
                            Text(
                              " $bloodAmount pin Blood Needed",
                              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontFamily: "Gotham", fontSize: 18.0),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0,),
                        Row(
                          children: <Widget>[
                            Icon(Icons.phone, color: Colors.blue,),
                            InkWell(
                              onTap: (){
                                _launchURL("tel:$phoneNumber");
                              },
                              child: Text(
                                "Call Now",
                                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontFamily: "Gotham", fontSize: 18.0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
