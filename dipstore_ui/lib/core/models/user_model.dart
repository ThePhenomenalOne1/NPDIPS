class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // Superadmin | Admin | ShopOwner | Customer | Guest
  final String status; // 'Active' or 'Suspended'
  final String? phoneNumber;
  final String? avatarUrl;
  final String? password; // In-memory only
  final List<String> permissions;
  final String? shopId; // If ShopOwner, their primary shop ID
  final bool isTwoFactorEnabled;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.status = 'Active',
    this.phoneNumber,
    this.avatarUrl,
    this.password,
    this.permissions = const [],
    this.shopId,
    this.isTwoFactorEnabled = false,
  });

  // Mock data factory
  factory UserModel.mock() {
    return const UserModel(
      id: 'usr_123456',
      name: "Naz's Account",
      email: "naz@dipstore.com",
      role: 'Merchant',
      status: 'Active',
      avatarUrl: 'https://ui-avatars.com/api/?name=Naz&background=bf8a2c&color=fff',
      password: 'password',
      permissions: ['view_analytics', 'manage_stores', 'manage_users'],
    );
  }

  factory UserModel.guest() {
    return const UserModel(
      id: 'guest_user',
      name: "Guest",
      email: "",
      role: 'Guest',
      status: 'Active',
    );
  }
}
