import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_dashboard/models/order.dart';
import 'package:mobile_dashboard/providers/order_provider.dart';
import 'package:mobile_dashboard/utils/constants.dart';
import 'package:mobile_dashboard/widgets/stat_card.dart';
import 'package:mobile_dashboard/widgets/order_list_item.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'today';
  final Map<String, int> _visibleLimits = {};

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.fetchOrders(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats - Now dynamic based on filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          StatCard(
                            title: 'Total Revenue',
                            value: currencyFormat.format(provider.getFilteredRevenue(_filter)),
                            icon: LucideIcons.dollarSign,
                            loading: provider.isLoading,
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            title: 'Total Orders',
                            value: provider.getFilteredOrderCount(_filter).toString(),
                            icon: LucideIcons.package,
                            loading: provider.isLoading,
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            title: 'Average Order',
                            value: currencyFormat.format(provider.getFilteredAverage(_filter)),
                            icon: LucideIcons.barChart3,
                            loading: provider.isLoading,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Filter Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Orders',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Constants.surfaceColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _FilterButton(
                                label: 'Today',
                                isSelected: _filter == 'today',
                                onTap: () => setState(() => _filter = 'today'),
                              ),
                              _FilterButton(
                                label: 'Past',
                                isSelected: _filter == 'past',
                                onTap: () => setState(() => _filter = 'past'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Orders List
                    if (provider.isLoading && provider.orders.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (_filter == 'today' && provider.todayOrders.isEmpty)
                      _buildEmptyState('No orders found for today')
                    else if (_filter == 'past' && provider.pastOrders.isEmpty)
                      _buildEmptyState('No past orders found')
                    else if (_filter == 'today')
                      _buildOrderList(provider.todayOrders, 'today')
                    else
                      ...provider.groupedPastOrders.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.parse(entry.key)),
                                style: const TextStyle(
                                  color: Constants.textMutedColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            _buildOrderList(entry.value, entry.key),
                          ],
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          message,
          style: const TextStyle(color: Constants.textMutedColor),
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, String dateKey) {
    final limit = _visibleLimits[dateKey] ?? 10;
    final itemsToShow = orders.take(limit).toList();
    final hasMore = orders.length > limit;

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemsToShow.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return OrderListItem(order: itemsToShow[index]);
          },
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _visibleLimits[dateKey] = limit + 10;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Constants.primaryColor.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Show more (+${orders.length - limit})'),
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Constants.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Constants.textMutedColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
