import 'package:blood_app_nepal/model/donor.dart';
import 'package:blood_app_nepal/screens/loading.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class RequestBlood extends StatefulWidget {

  final Donor currentUser;

  RequestBlood(this.currentUser);

  @override
  _RequestBloodState createState() => _RequestBloodState();
}

class _RequestBloodState extends State<RequestBlood> {

  final bloodRequestRef = Firestore.instance.collection('request');

  bool isRequesting = false;

  final _formKey = GlobalKey<FormState>();


  TextEditingController displayNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController bloodGroupController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController bloodNeedDateController = TextEditingController();


  getUserLocation() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.lowest);
    List<Placemark> placemarks= await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress = '${placemark.locality}, ${placemark.administrativeArea}';
    addressController.text = completeAddress;
  }

  requestBlood() async {

    DocumentSnapshot doc = await bloodRequestRef.document(Uuid().v4()).get();

    bloodRequestRef.document(Uuid().v4()).setData({
      "location":addressController.text,
      "bloodGroup":bloodGroupController.text,
      "phoneNumber":phoneNumberController.text,
      "bloodAmount":amountController.text,
      "bloodNeededDate": bloodNeedDateController.text,
    });

  }

  handleBloodRequest() async {

    setState(() {
      isRequesting = true;
    });

    await requestBlood();

    setState(() {
      isRequesting = false;
      Navigator.pop(context);
    });



  }

  pickDate() async {
    DateTime date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year+1),
    );

    if(date !=null){
      setState(() {
        bloodNeedDateController.text = date.year.toString() +"-"+ date.month.toString() +"-"+date.day.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Request Blood"),
      ),
     body: Builder(builder: (context){
       return isRequesting?circularLoading():Padding(
         padding: const EdgeInsets.all(10.0),
         child: Form(
           key: _formKey,
           child: ListView(
             children: <Widget>[
               Padding(
                 padding: const EdgeInsets.only(top:8.0),
                 child: TextFormField(
                   validator: (value) {
                     if (value.isEmpty) {
                       return 'Donor needs your Location';
                     }
                     return null;
                   },
                   decoration: InputDecoration(
                       fillColor: Colors.grey,
                       suffixIcon: IconButton(icon: Icon(Icons.location_on, color: Colors.red,), onPressed: getUserLocation),
                       hintText: "Your Location",
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(10.0),
                       )
                   ),
                   controller: addressController,
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(top:8.0),
                 child: TextFormField(
                   keyboardType: TextInputType.numberWithOptions(),
                   validator: (value) {
                     if (value.isEmpty) {
                       return 'Blood Amount is Required';
                     }
                     return null;
                   },
                   decoration: InputDecoration(
                       fillColor: Colors.grey,
                       hintText: "Blood Amount (in Pin)",
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(10.0),
                       )
                   ),
                   controller: amountController,
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(top:8.0),
                 child: TextFormField(
                   keyboardType: TextInputType.numberWithOptions(),
                   validator: (value) {
                     if (value.isEmpty || value.length!=10) {
                       return 'Provide 10 Digit Number';
                     }
                     return null;
                   },
                   decoration: InputDecoration(
                       hintText: "Phone Number",
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(10.0),
                       )
                   ),
                   controller: phoneNumberController,
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(top:8.0),
                 child: DropdownButtonFormField(
                   validator: (value) => value == null
                       ? 'Please provide Blood Group' : null,
                   onChanged: (val){
                     bloodGroupController.text = val;
                   },
                   decoration: InputDecoration(
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(10.0),
                       )
                   ),
                   hint: Text("Blood Group"),
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
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(top:8.0),
                 child: TextFormField(
                   onTap: (){
                     pickDate();
                   },
                   validator: (value) {
                     if (value.isEmpty) {
                       return 'Please Provide Date';
                     }
                     return null;
                   },
                   decoration: InputDecoration(
                       hintText: "When Do you Need?",
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(10.0),
                       ),
                       fillColor: Colors.pinkAccent
                   ),
                   controller: bloodNeedDateController,
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: FlatButton(
                     child: Text("Request Blood", style: TextStyle(color: Colors.white, fontSize: 20.0),),
                     color: Theme.of(context).primaryColor,
                     onPressed: () {

                       if (_formKey.currentState.validate()) {
                         Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing Data')));
                         handleBloodRequest();
                       }
                     }
                 ),
               ),

             ],
           ),
         ),
       );
     })
    );
  }
}
