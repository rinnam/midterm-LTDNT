import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String email;
  final String matkhau;
  final String hoten;
  final String hinhanh;

  UserModel({
    this.id,
    required this.email,
    required this.matkhau,
    required this.hoten,
    required this.hinhanh,
  });

  // Tạo UserModel từ DocumentSnapshot Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      matkhau: data['matkhau'] ?? '',
      hoten: data['hoten'] ?? '',
      hinhanh: data['hinhanh'] ?? '',
    );
  }

  // Chuyển UserModel thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'matkhau': matkhau,
      'hoten': hoten,
      'hinhanh': hinhanh,
    };
  }
}
