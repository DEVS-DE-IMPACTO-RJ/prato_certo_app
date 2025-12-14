class InventoryItem {
  final String id;
  final String collaboratorProfileId;
  final String name;
  final String category;
  final num quantity;
  final String unit;
  final DateTime? expiresAt; // <-- AGORA É NULLABLE
  final DateTime updatedAt;

  InventoryItem({
    required this.id,
    required this.collaboratorProfileId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.expiresAt, // <-- Não é mais 'required' obrigatório
    required this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] ?? '',
      collaboratorProfileId: json['collaboratorProfileId'] ?? '',
      name: json['name'] ?? 'Sem nome',
      category: json['category'] ?? 'Geral',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? 'un',
      // Lógica de segurança para data nula
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Opcional: Se precisar enviar de volta pro backend futuramente
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collaboratorProfileId': collaboratorProfileId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expiresAt': expiresAt?.toIso8601String(), // Envia null se não tiver
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}