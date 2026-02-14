import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_dashboard/models/order.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;
  RealtimeChannel? _subscription;
  
  // Connectivity state
  bool _isOffline = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOffline => _isOffline;

  // Stats calculation helpers
  double getFilteredRevenue(String filter) {
    final list = filter == 'today' ? todayOrders : pastOrders;
    return list.fold(0.0, (sum, order) => sum + order.price);
  }

  int getFilteredOrderCount(String filter) {
    return filter == 'today' ? todayOrders.length : pastOrders.length;
  }

  double getFilteredAverage(String filter) {
    final count = getFilteredOrderCount(filter);
    return count > 0 ? getFilteredRevenue(filter) / count : 0.0;
  }

  List<Order> get todayOrders {
    final now = DateTime.now();
    return _orders.where((o) {
      return o.createdAt.year == now.year &&
             o.createdAt.month == now.month &&
             o.createdAt.day == now.day;
    }).toList();
  }

  List<Order> get pastOrders {
    final now = DateTime.now();
    return _orders.where((o) {
      return !(o.createdAt.year == now.year &&
               o.createdAt.month == now.month &&
               o.createdAt.day == now.day);
    }).toList();
  }

  // Grouped Past Orders logic
  Map<String, List<Order>> get groupedPastOrders {
    final Map<String, List<Order>> groups = {};
    for (var order in pastOrders) {
      final dateKey = DateFormat('yyyy-MM-dd').format(order.createdAt);
      if (!groups.containsKey(dateKey)) {
        groups[dateKey] = [];
      }
      groups[dateKey]!.add(order);
    }
    return groups;
  }

  OrderProvider() {
    fetchOrders();
    _setupSubscription();
    _setupConnectivity();
  }

  Future<void> fetchOrders() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await Supabase.instance.client
          .from('orders')
          .select('number, description, price, created_at')
          .order('created_at', ascending: false);

      _orders = (response as List).map((json) => Order.fromJson(json)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupSubscription() {
    _subscription = Supabase.instance.client
        .channel('public:orders')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            fetchOrders();
          },
        )
        .subscribe();
  }

  Future<void> _setupConnectivity() async {
    // Check initial state
    final results = await Connectivity().checkConnectivity();
    _updateConnectivity(results);

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateConnectivity(results);
    });
  }

  void _updateConnectivity(List<ConnectivityResult> results) {
    // Check if any result is not 'none'
    _isOffline = results.every((result) => result == ConnectivityResult.none);
    notifyListeners();
  }

  @override
  void dispose() {
    if (_subscription != null) {
      Supabase.instance.client.removeChannel(_subscription!);
    }
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
