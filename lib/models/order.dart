class Order {
  final int? number;
  final String description;
  final double price;
  final DateTime createdAt;

  Order({
    this.number,
    required this.description,
    required this.price,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      number: json['number'],
      description: json['description'] ?? 'No description',
      price: (json['price'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
