
import 'package:cloud_firestore/cloud_firestore.dart';

class Donor{
  String id;
  String displayName;
  String photoUrl;
  String location;
  String phoneNumber;
  String bloodGroup;
  String gender;
  String dateOfBirth;

  Donor({this.id, this.displayName, this.photoUrl, this.location, this.bloodGroup, this.phoneNumber, this.gender, this.dateOfBirth});

  factory Donor.fromDocument(DocumentSnapshot doc) {
    return Donor(
      id: doc['id'],
      displayName: doc['displayName'],
      photoUrl: doc['photoUrl'],
      location: doc['location'],
      bloodGroup: doc['bloodGroup'],
      phoneNumber: doc['phoneNumber'],
      gender: doc['gender'],
      dateOfBirth: doc['dateOfBirth'],
    );
  }
}