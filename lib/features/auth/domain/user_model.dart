import 'dart:convert';

enum UserRole {
  member,
  committeeAdmin,
}

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? mahalId;
  final UserRole role;
  final String houseName;
  final String familyId;
  final String? avatarUrl;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.mahalId,
    required this.role,
    this.houseName = 'Baitul Noor',
    this.familyId = 'EK-FAM-142',
    this.avatarUrl,
    this.createdAt,
  });

  bool get isAdmin => role == UserRole.committeeAdmin;

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? mahalId,
    UserRole? role,
    String? houseName,
    String? familyId,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      mahalId: mahalId ?? this.mahalId,
      role: role ?? this.role,
      houseName: houseName ?? this.houseName,
      familyId: familyId ?? this.familyId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'mahalId': mahalId,
      'role': role.index,
      'houseName': houseName,
      'familyId': familyId,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String? ?? 'usr_default',
      name: map['name'] as String? ?? 'Mahal Member',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      mahalId: map['mahalId'] as String?,
      role: map['role'] == 1 ? UserRole.committeeAdmin : UserRole.member,
      houseName: map['houseName'] as String? ?? 'Baitul Noor',
      familyId: map['familyId'] as String? ?? 'EK-FAM-142',
      avatarUrl: map['avatarUrl'] as String?,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'] as String) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class MahalModel {
  final String id;
  final String name;
  final String code;
  final String district;
  final String location;
  final String president;
  final String secretary;
  final String phone;
  final Map<String, String> jamaathOverrides;

  const MahalModel({
    required this.id,
    required this.name,
    required this.code,
    required this.district,
    required this.location,
    required this.president,
    required this.secretary,
    required this.phone,
    required this.jamaathOverrides,
  });
}
