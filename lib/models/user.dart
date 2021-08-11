import 'package:firebase_database/firebase_database.dart';

class UserFormData {
  String? id;
  String? name;
  String? email;
  String? mobileNo;
  String? password;
  String? confirmPassword;

  UserFormData({
    this.id = '',
    this.name = '',
    this.email = '',
    this.mobileNo = '',
    this.password = '',
    this.confirmPassword = '',
  });

  UserFormData.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key ?? '';
    name = dataSnapshot.value['name'];
    email = dataSnapshot.value['email'];
    mobileNo = dataSnapshot.value['phone'];
  }

  @override
  String toString() {
    return 'UserFormData(id: $id, name: $name, email: $email, mobileNo: $mobileNo, password: $password, confirmPassword: $confirmPassword)';
  }
}
