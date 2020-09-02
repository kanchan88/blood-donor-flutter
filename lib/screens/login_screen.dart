import 'package:blood_app_nepal/screens/drawer.dart';
import 'package:blood_app_nepal/screens/loading.dart';
import 'package:blood_app_nepal/screens/blood_requests.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/donor.dart';
import 'edit_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geolocator/geolocator.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
//  final StorageReference storageRef = FirebaseStorage.instance.ref();
  final donorRef = Firestore.instance.collection('donor');
//
  Donor currentUser;
  bool wannaSearch = false;

  TextEditingController userBloodQuery = TextEditingController();
  TextEditingController userLocationQuery = TextEditingController();

  List<dynamic> donors = [];
//
//
  @override
  void initState() {
    super.initState();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });

    // Re-authenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });

    showDonors(context);
  }

  bool isAuth = false;

  loginWithGoogle(){
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  getUserLocation() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.lowest);
    List<Placemark> placemarks= await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress = '${placemark.locality}';
    userLocationQuery.text = completeAddress;
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFireStore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  showDonors(context) async {

    final QuerySnapshot snapshot = await donorRef.getDocuments();

    setState(() {
      donors = snapshot.documents;
    });
  }
//


  createUserInFireStore() async {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await donorRef.document(user.id).get();

    if (!doc.exists) {

      // 3) get username from create account, use it to make new user document in users collection
      donorRef.document(user.id).setData({
        "id": user.id,
        "displayName": user.displayName,
        "photoUrl": user.photoUrl,
        "location": "",
        "locationSearch":"",
        "phoneNumber":"",
        "bloodGroup":"",
        'gender':"",
        'dateOfBirth':"",
      });

      doc = await donorRef.document(user.id).get();
    }

    currentUser = Donor.fromDocument(doc);

  }



  StreamBuilder showSearchResults(){

    return StreamBuilder(
      stream: donorRef.orderBy('location')
          .where('locationSearch', arrayContains: userLocationQuery.text)
          .where('bloodGroup', isEqualTo: userBloodQuery.text)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularLoading();
        }
        print(userBloodQuery.text);
        List<ShowDonors> allDonors = [];
        snapshot.data.documents.forEach((doc) {
          allDonors.add(ShowDonors.fromDocument(doc));
        });

        return Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              allDonors.length==0?Text("No Donors Found"):Column(
                children: allDonors,
              ),
            ],
          ),
        );

      },
    );

  }

  Scaffold unAuthScreen(){
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(left: 35.0, right: 20.0,),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(padding: EdgeInsets.only(top: 10.0, bottom: 30.0),child: Text("Donate Blood or Find Donor!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: "Gotham", fontSize: 20.0 ),)),
              Container(padding: EdgeInsets.only(top: 30.0, bottom: 50.0),child: Image.asset('assets/img/logo.png', height: MediaQuery.of(context).size.height*0.2,)),
              Container(
                  padding: const EdgeInsets.only(top:20.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        height:50.0,
                        child: Image.asset('assets/img/g_logo.png',),
                      ),
                      Container(
                        height: 50.0,
                        width: MediaQuery.of(context).size.width*.7,
                        child: FlatButton(
                          onPressed:loginWithGoogle,
                          child: Text("Continue with Google", style: TextStyle(color: Colors.red, fontFamily: "Gotham", fontSize: 20.0 ),),
                          color:Colors.white ,
                        ),
                      ),
                    ],
                  )
              ),
//              Container(
//                padding: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.2),
//                child: Column(
//                  children: <Widget>[
//                    Text("SUPPORTED BY", style: TextStyle(fontFamily: "Gotham", fontWeight:FontWeight.bold,fontSize: 18.0, color: Colors.red),),
//                    SizedBox(height: 10.0,),
//                    Image.asset('assets/img/supporter.png', height: 60.0,),
//                  ],
//                ),
//              )
            ],
          ),
        ),
      ),
      bottomSheet: InkWell(onTap:()=>launch("https://yourkoseli.com"),child: Image.asset('assets/img/supporter.png', width: double.infinity,)),
    );
  }

  Scaffold authScreen(){
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red,
      ),
      drawer: MainDrawer(googleSignIn),
      body: ListView(
        children: <Widget>[
          Stack(
            children:<Widget>[
              Container(
                height: 150.0,
                color: Colors.red,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text("Find a Donor", style: TextStyle(fontFamily: "Gotham", fontSize: 20.0, color: Colors.black),),
                      ),
                      Container(
                        padding: EdgeInsets.only(left:30.0, right: 30.0, top: 10.0, bottom: 10.0),
                        child: TextField(
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          controller: userLocationQuery,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(icon: Icon(Icons.my_location), onPressed: getUserLocation),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            hintText: "Location ...",
                          ),
                        )
                      ),
                      SizedBox(height: 10.0,),
                      Padding(
                        padding: EdgeInsets.only(left:30.0, right: 30.0, top: 10.0, bottom: 10.0),
                        child:DropdownButtonFormField(
                          decoration: InputDecoration(
                            suffixIcon: IconButton(icon: Icon(Icons.clear), onPressed: (){
                              setState(() {
                                wannaSearch=false;
                                userLocationQuery.clear();
                                userBloodQuery.clear();
                                FocusScope.of(context).unfocus();
                              });
                            }),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )
                          ),
                          hint: Text("Choose Blood Group"),
                          items: [
                            DropdownMenuItem(child: Text("A+"),
                              value: "A+",),
                            DropdownMenuItem(child: Text("B+"),
                              value: "B+",),
                            DropdownMenuItem(child: Text("O+"),
                              value: "O+",),
                            DropdownMenuItem(child: Text("AB+"),
                              value: "AB+",),
                            DropdownMenuItem(child: Text("A-"),
                              value: "A-",),
                            DropdownMenuItem(child: Text("B-"),
                              value: "B-",),
                            DropdownMenuItem(child: Text("O-"),
                              value: "O-",),
                            DropdownMenuItem(child: Text("AB-"),
                              value: "AB-",),
                          ],
                          onChanged: (val){
                            setState(() {
                              userBloodQuery.text = val;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 10.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left:20.0, bottom: 10.0),
                            child: RaisedButton(
                              onPressed: (){
                                setState(() {
                                  wannaSearch = true;
                                  FocusScope.of(context).unfocus();
                                });
                              },
                              color: Colors.red,
                              child: Text("Search", style: TextStyle(fontFamily: "Gotham", fontSize: 20.0, color: Colors.white),),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(color: Colors.red)),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left:20.0, bottom: 10.0, right: 20.0),
                            child: RaisedButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfile(currentUser, authScreen())));
                              },
                              color: Colors.red,
                              child: Text("Be Donor", style: TextStyle(fontFamily: "Gotham", fontSize: 20.0, color: Colors.white),),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(color: Colors.red)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ]
          ),
          SizedBox(height: 20.0,),
          Text("  Recent Donors", style: TextStyle(fontFamily: "Gotham", fontSize: 22.0, color: Colors.black),),
          SizedBox(height: 10.0,),
          wannaSearch?showSearchResults():StreamBuilder(
              stream: donorRef.where("bloodGroup", isGreaterThan: "").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularLoading();
                }
                List<ShowDonors> allDonors = [];
                snapshot.data.documents.forEach((doc) {
                  allDonors.add(ShowDonors.fromDocument(doc));
                });

                return Container(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: allDonors,
                  ),
                );
              },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          child: Icon(Icons.add),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestBlood(currentUser)));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth?authScreen():unAuthScreen();
  }
}

class ShowDonors extends StatelessWidget {

  final String displayName;
  final String location;
  final String bloodGroup;
  final String gender;
  final String phoneNumber;

  ShowDonors({
    this.displayName,
    this.location,
    this.phoneNumber,
    this.bloodGroup,
    this.gender,
  });

  factory ShowDonors.fromDocument(DocumentSnapshot doc) {
    return ShowDonors(
      displayName: doc['displayName'],
      location: doc['location'],
      bloodGroup: doc['bloodGroup'],
      phoneNumber: doc['phoneNumber'],
      gender: doc['gender'],
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
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      displayName,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontFamily: "Gotham",
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(Icons.person_pin, color: Colors.redAccent,),
                            Text(
                              "$gender",
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



