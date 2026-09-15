import 'package:flutter/material.dart';

class ChurchTenant {
  final String id;
  final String name;
  final String code; // Ej: REB-1054
  final String pastorName;
  final String email;
  final Color primaryColor;
  final String? logoUrl;
  final String address;
  final String phone;
  final DateTime createdAt;

  const ChurchTenant({
    required this.id,
    required this.name,
    required this.code,
    required this.pastorName,
    required this.email,
    required this.primaryColor,
    this.logoUrl,
    this.address = 'Calle Principal #123, Colonia Centro',
    this.phone = '+52 55 1234 5678',
    required this.createdAt,
  });

  ChurchTenant copyWith({
    String? id,
    String? name,
    String? code,
    String? pastorName,
    String? email,
    Color? primaryColor,
    String? logoUrl,
    String? address,
    String? phone,
    DateTime? createdAt,
  }) {
    return ChurchTenant(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      pastorName: pastorName ?? this.pastorName,
      email: email ?? this.email,
      primaryColor: primaryColor ?? this.primaryColor,
      logoUrl: logoUrl ?? this.logoUrl,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
