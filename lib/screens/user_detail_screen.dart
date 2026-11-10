import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  // Xây dựng widget hiển thị ảnh, hỗ trợ cả URL và base64
  Widget _buildUserImage() {
    if (user.hinhanh.isEmpty) {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, size: 100, color: Colors.white),
      );
    }

    // Nếu là base64 data URL
    if (user.hinhanh.startsWith('data:')) {
      try {
        final parts = user.hinhanh.split(',');
        if (parts.length == 2) {
          final bytes = base64Decode(parts[1]);
          return ClipOval(
            child: Image.memory(
              bytes,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          );
        }
      } catch (_) {}
    }

    // Nếu là URL thường
    return ClipOval(
      child: Image.network(
        user.hinhanh,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.broken_image, size: 100, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CHI TIẾT NGƯỜI DÙNG',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Hình ảnh đại diện
                  _buildUserImage(),
                  const SizedBox(height: 24),

                  // Tên
                  Text(
                    user.hoten,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Thông tin chi tiết
                  _buildInfoRow(Icons.email, 'Email', user.email),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.lock, 'Mật khẩu', user.matkhau),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.person, 'Họ tên', user.hoten),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.image,
                    'Hình ảnh',
                    user.hinhanh.isNotEmpty
                        ? (user.hinhanh.startsWith('data:')
                            ? 'Ảnh base64 (đã chọn từ thiết bị)'
                            : user.hinhanh)
                        : 'Chưa có hình ảnh',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.indigo, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
