import 'package:equatable/equatable.dart';

/// Salary record model
class SalaryRecordModel extends Equatable {
  final String id;
  final String teacherId;
  final int month; // 1-12
  final int year;
  final double totalHours;
  final double totalAmount;
  final double fines;
  final double bonuses;
  final double netAmount;
  final String status; // 'pending', 'paid', 'cancelled'
  final String? paymentMethod;
  final String? notes;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SalaryRecordModel({
    required this.id,
    required this.teacherId,
    required this.month,
    required this.year,
    required this.totalHours,
    required this.totalAmount,
    this.fines = 0,
    this.bonuses = 0,
    required this.netAmount,
    this.status = 'pending',
    this.paymentMethod,
    this.notes,
    this.paidAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory SalaryRecordModel.fromJson(Map<String, dynamic> json) {
    return SalaryRecordModel(
      id: json['\$id'] ?? '',
      teacherId: json['teacherId'] ?? '',
      month: json['month'] ?? 1,
      year: json['year'] ?? DateTime.now().year,
      totalHours: (json['totalHours'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      fines: (json['fines'] ?? 0).toDouble(),
      bonuses: (json['bonuses'] ?? 0).toDouble(),
      netAmount: (json['netAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'],
      notes: json['notes'],
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'month': month,
      'year': year,
      'totalHours': totalHours,
      'totalAmount': totalAmount,
      'fines': fines,
      'bonuses': bonuses,
      'netAmount': netAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'paidAt': paidAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  SalaryRecordModel copyWith({
    String? id,
    String? teacherId,
    int? month,
    int? year,
    double? totalHours,
    double? totalAmount,
    double? fines,
    double? bonuses,
    double? netAmount,
    String? status,
    String? paymentMethod,
    String? notes,
    DateTime? paidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SalaryRecordModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      month: month ?? this.month,
      year: year ?? this.year,
      totalHours: totalHours ?? this.totalHours,
      totalAmount: totalAmount ?? this.totalAmount,
      fines: fines ?? this.fines,
      bonuses: bonuses ?? this.bonuses,
      netAmount: netAmount ?? this.netAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        teacherId,
        month,
        year,
        totalHours,
        totalAmount,
        fines,
        bonuses,
        netAmount,
        status,
        paymentMethod,
        notes,
        paidAt,
        createdAt,
        updatedAt,
      ];
}
