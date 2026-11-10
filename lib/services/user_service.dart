import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Thêm người dùng mới
  Future<void> addUser(UserModel user) async {
    await _usersCollection.add(user.toMap());
  }

  // Lấy danh sách tất cả người dùng (Stream realtime)
  Stream<List<UserModel>> getUsers() {
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  // Cập nhật thông tin người dùng
  Future<void> updateUser(String id, UserModel user) async {
    await _usersCollection.doc(id).update(user.toMap());
  }

  // Xóa người dùng
  Future<void> deleteUser(String id) async {
    await _usersCollection.doc(id).delete();
  }

  // Tìm kiếm người dùng theo email hoặc tên
  Stream<List<UserModel>> searchUsers(String query) {
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) =>
              user.email.toLowerCase().contains(query.toLowerCase()) ||
              user.hoten.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Đăng nhập - kiểm tra email và mật khẩu trong Firestore
  Future<UserModel?> login(String email, String matkhau) async {
    final querySnapshot = await _usersCollection
        .where('email', isEqualTo: email)
        .where('matkhau', isEqualTo: matkhau)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return UserModel.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }
}
