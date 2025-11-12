import 'package:equatable/equatable.dart';

class Reader extends Equatable {
  final int? id;
  final String name;
  final String? studentId;
  final String? className;
  final String? phone;
  final String? email;
  final String? address;
  final DateTime? createdAt;

  const Reader({
    this.id,
    required this.name,
    this.studentId,
    this.className,
    this.phone,
    this.email,
    this.address,
    this.createdAt,
  });

  factory Reader.fromJson(Map<String, dynamic> json) {
    return Reader(
      id: json['id'] as int?,
      name: json['name'] as String,
      studentId: json['student_id'] as String?,
      className: json['class'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : (json['created_at'] is String
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'student_id': studentId,
      'class': className,
      'phone': phone,
      'email': email,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Reader copyWith({
    int? id,
    String? name,
    String? studentId,
    String? className,
    String? phone,
    String? email,
    String? address,
    DateTime? createdAt,
  }) {
    return Reader(
      id: id ?? this.id,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      className: className ?? this.className,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        studentId,
        className,
        phone,
        email,
        address,
        createdAt,
      ];
}