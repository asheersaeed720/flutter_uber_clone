class UserFormData {
  String name;
  String email;
  String mobileNo;
  String password;
  String confirmPassword;

  UserFormData({
    this.name = '',
    this.email = '',
    this.mobileNo = '',
    this.password = '',
    this.confirmPassword = '',
  });

  @override
  String toString() {
    return 'UserFormData(name: $name, email: $email, mobileNo: $mobileNo, password: $password, confirmPassword: $confirmPassword)';
  }
}
