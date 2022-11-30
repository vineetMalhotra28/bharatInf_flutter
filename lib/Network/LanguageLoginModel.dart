class LanguageModel {
  String? status;
  int? statusCode;
  String? message;
  Data? data;

  LanguageModel({this.status, this.statusCode, this.message, this.data});

  LanguageModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['status_code'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['status_code'] = this.statusCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? lang;
  Null? image;
  String? byEmail;
  String? phone;
  String? sendcode;
  String? alert;
  String? email;
  String? password;
  String? login;
  String? forgetPassword;
  String? bottomAcc;
  String? start;
  Null? createdAt;
  Null? updatedAt;

  Data(
      {this.id,
      this.lang,
      this.image,
      this.byEmail,
      this.phone,
      this.sendcode,
      this.alert,
      this.email,
      this.password,
      this.login,
      this.forgetPassword,
      this.bottomAcc,
      this.start,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lang = json['lang'];
    image = json['image'];
    byEmail = json['by_email'];
    phone = json['phone'];
    sendcode = json['sendcode'];
    alert = json['alert'];
    email = json['email'];
    password = json['password'];
    login = json['login'];
    forgetPassword = json['forget_password'];
    bottomAcc = json['bottom_acc'];
    start = json['start'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['lang'] = this.lang;
    data['image'] = this.image;
    data['by_email'] = this.byEmail;
    data['phone'] = this.phone;
    data['sendcode'] = this.sendcode;
    data['alert'] = this.alert;
    data['email'] = this.email;
    data['password'] = this.password;
    data['login'] = this.login;
    data['forget_password'] = this.forgetPassword;
    data['bottom_acc'] = this.bottomAcc;
    data['start'] = this.start;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
