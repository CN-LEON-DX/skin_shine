class UserModel {
  final String userId;
  final String accountId;
  final String email;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final bool isVerified;
  final bool isExpert;
  final String role;
  final String? skinType;
  final String? expertId;
  final String? expertTitle;
  final String? expertSpecialty;
  final int cartCount;

  UserModel({
    required this.userId,
    required this.accountId,
    required this.email,
    required this.username,
    this.fullName,
    this.avatarUrl,
    required this.isVerified,
    required this.isExpert,
    required this.role,
    this.skinType,
    this.expertId,
    this.expertTitle,
    this.expertSpecialty,
    required this.cartCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      accountId: json['account_id'],
      email: json['email'],
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      isVerified: json['is_verified'] ?? false,
      isExpert: json['is_expert'] ?? false,
      role: json['role'] ?? 'user',
      skinType: json['skin_type'],
      expertId: json['expert_id'],
      expertTitle: json['expert_title'],
      expertSpecialty: json['expert_specialty'],
      cartCount: json['cart_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'account_id': accountId,
      'email': email,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'is_expert': isExpert,
      'role': role,
      'skin_type': skinType,
      'expert_id': expertId,
      'expert_title': expertTitle,
      'expert_specialty': expertSpecialty,
      'cart_count': cartCount,
    };
  }
} 