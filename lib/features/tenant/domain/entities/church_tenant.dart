import 'package:flutter/material.dart';

class ChurchTenant {
  final String id;
  final String name; // Nombre Completo u Oficial (ej. Iglesia Bautista Fundamental Independiente El Alfarero)
  final String shortName; // Nombre Corto / Distintivo (ej. El Alfarero)
  final String code; // Ej: IBFIEA-150926
  final String pastorName;
  final String email;
  final Color primaryColor;
  final String? logoUrl;
  final String address;
  final String phone;
  final String? motto; // lema_o_vision
  final DateTime createdAt;

  const ChurchTenant({
    required this.id,
    required this.name,
    this.shortName = '',
    required this.code,
    required this.pastorName,
    required this.email,
    required this.primaryColor,
    this.logoUrl,
    this.motto,
    this.address = 'Costado Oeste del Parque Central, Managua, Nicaragua',
    this.phone = '+505 2222 3456',
    required this.createdAt,
  });

  String get displayName => shortName.trim().isNotEmpty ? shortName.trim() : name;

  ChurchTenant copyWith({
    String? id,
    String? name,
    String? shortName,
    String? code,
    String? pastorName,
    String? email,
    Color? primaryColor,
    String? logoUrl,
    String? motto,
    String? address,
    String? phone,
    DateTime? createdAt,
  }) {
    return ChurchTenant(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      code: code ?? this.code,
      pastorName: pastorName ?? this.pastorName,
      email: email ?? this.email,
      primaryColor: primaryColor ?? this.primaryColor,
      logoUrl: logoUrl ?? this.logoUrl,
      motto: motto ?? this.motto,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
