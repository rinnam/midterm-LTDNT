import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'add_user_screen.dart';
import 'edit_user_screen.dart';
import 'user_detail_screen.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  final UserModel currentUser;

  const AdminScreen({super.key, required this.currentUser});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _unfocusSearch() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
  }

  void _navigateTo(Widget screen) {
    _unfocusSearch();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng xuất',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa người dùng "${user.hoten}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _userService.deleteUser(user.id!);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa người dùng thành công!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi khi xóa: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(UserModel user, {double radius = 25}) {
    if (user.hinhanh.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.indigo.shade100,
        child: Icon(Icons.person, size: radius * 1.2, color: Colors.indigo),
      );
    }

    if (user.hinhanh.startsWith('data:')) {
      try {
        final parts = user.hinhanh.split(',');
        if (parts.length == 2) {
          final bytes = base64Decode(parts[1]);
          return CircleAvatar(
            radius: radius,
            backgroundImage: MemoryImage(bytes),
          );
        }
      } catch (_) {}
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(user.hinhanh),
      onBackgroundImageError: (_, _) {},
    );
  }

  Widget _buildTableImage(UserModel user) {
    if (user.hinhanh.isEmpty) {
      return const Icon(Icons.person, size: 40);
    }

    if (user.hinhanh.startsWith('data:')) {
      try {
        final parts = user.hinhanh.split(',');
        if (parts.length == 2) {
          final bytes = base64Decode(parts[1]);
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              bytes,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          );
        }
      } catch (_) {}
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        user.hinhanh,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.person, size: 40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusSearch,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'QUẢN LÝ NGƯỜI DÙNG',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            // Hiển thị thông tin admin đang đăng nhập
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  'Xin chào, ${widget.currentUser.hoten}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Đăng xuất',
              onPressed: () {
                _unfocusSearch();
                _logout();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Thanh tìm kiếm
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.indigo.shade50,
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _unfocusSearch(),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tên hoặc email...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _unfocusSearch();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
            // Danh sách người dùng
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: _searchQuery.isEmpty
                    ? _userService.getUsers()
                    : _userService.searchUsers(_searchQuery),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Lỗi: ${snapshot.error}'),
                        ],
                      ),
                    );
                  }

                  final users = snapshot.data ?? [];

                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Chưa có người dùng nào.\nNhấn nút + để thêm mới.'
                                : 'Không tìm thấy kết quả.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive: DataTable trên web/màn hình lớn, ListView trên mobile
                      if (constraints.maxWidth > 600) {
                        return _buildDataTable(users);
                      } else {
                        return _buildListView(users);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateTo(const AddUserScreen()),
          backgroundColor: Colors.indigo,
          icon: const Icon(Icons.person_add, color: Colors.white),
          label: const Text('Thêm người dùng',
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // Hiển thị dạng bảng cho web/màn hình lớn
  Widget _buildDataTable(List<UserModel> users) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
          border: TableBorder.all(color: Colors.grey.shade300),
          columns: const [
            DataColumn(label: Text('STT', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Hình ảnh', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Họ tên', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Mật khẩu', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: List.generate(users.length, (index) {
            final user = users[index];
            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(
                  GestureDetector(
                    onTap: () => _showImageDialog(user),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: _buildTableImage(user),
                    ),
                  ),
                ),
                DataCell(Text(user.hoten)),
                DataCell(Text(user.email)),
                DataCell(Text('••••••••')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'Xem chi tiết',
                        onPressed: () => _navigateTo(UserDetailScreen(user: user)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Sửa',
                        onPressed: () => _navigateTo(EditUserScreen(user: user)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Xóa',
                        onPressed: () {
                          _unfocusSearch();
                          _confirmDelete(user);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Hiển thị dạng danh sách cho mobile
  Widget _buildListView(List<UserModel> users) {
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(8),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          elevation: 2,
          child: ListTile(
            leading: GestureDetector(
              onTap: () => _showImageDialog(user),
              child: _buildAvatar(user),
            ),
            title: Text(
              user.hoten,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(user.email),
            trailing: PopupMenuButton<String>(
              onOpened: _unfocusSearch,
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _navigateTo(UserDetailScreen(user: user));
                    break;
                  case 'edit':
                    _navigateTo(EditUserScreen(user: user));
                    break;
                  case 'delete':
                    _unfocusSearch();
                    _confirmDelete(user);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Xem chi tiết'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Sửa'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xóa'),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _navigateTo(UserDetailScreen(user: user)),
          ),
        );
      },
    );
  }

  // Hiển thị hình ảnh to khi nhấn vào avatar
  void _showImageDialog(UserModel user) {
    if (user.hinhanh.isEmpty) return;
    _unfocusSearch();
    Widget imageWidget;
    if (user.hinhanh.startsWith('data:')) {
      try {
        final parts = user.hinhanh.split(',');
        final bytes = base64Decode(parts[1]);
        imageWidget = Image.memory(bytes, fit: BoxFit.contain);
      } catch (_) {
        imageWidget = const Icon(Icons.broken_image, size: 100);
      }
    } else {
      imageWidget = Image.network(
        user.hinhanh,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Padding(
          padding: EdgeInsets.all(32),
          child: Icon(Icons.broken_image, size: 100),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(user.hoten),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            InteractiveViewer(
              child: imageWidget,
            ),
          ],
        ),
      ),
    );
  }
}
