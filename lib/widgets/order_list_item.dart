import 'package:flutter/material.dart';
import 'package:mobile_dashboard/models/order.dart';
import 'package:mobile_dashboard/utils/constants.dart';
import 'package:intl/intl.dart';

class OrderListItem extends StatelessWidget {
  final Order order;

  const OrderListItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Constants.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#${order.number ?? '?' }',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Constants.accentColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  timeFormat.format(order.createdAt),
                  style: const TextStyle(
                    color: Constants.textMutedColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${order.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF10B981), // Emerald green for price
            ),
          ),
        ],
      ),
    );
  }
}
