import 'package:flutter/foundation.dart';
import '../../features/cart/models/cart_item_model.dart';
import '../../features/cart/models/order_model.dart';
import 'dart:math';

class CartProvider extends ChangeNotifier {
  // Map<storeId, List<CartItemModel>>
  final Map<String, List<CartItemModel>> _cartsByStore = {};
  
  // Keep track of the "current" store being viewed/checked out
  String? _activeStoreId;

  final List<OrderModel> _orderedItems = [];

  List<OrderModel> get orderedItems => _orderedItems;

  // Get items for specific store or active store
  List<CartItemModel> getItemsForStore(String storeId) => _cartsByStore[storeId] ?? [];
  List<CartItemModel> get activeCartItems => _activeStoreId != null ? _cartsByStore[_activeStoreId] ?? [] : [];

  // Total items across ALL stores (for global badge)
  int get itemCount {
    int total = 0;
    _cartsByStore.forEach((_, items) {
       total += items.fold(0, (sum, item) => sum + item.quantity);
    });
    return total;
  }
  
  // Cart Subtotal for SPECIFIC store
  double getSubtotal(String storeId) {
    final items = _cartsByStore[storeId] ?? [];
    return items.fold(0, (sum, item) => sum + item.total);
  }
  
  double getTotal(String storeId) {
    return getSubtotal(storeId) * 1.05; // 5% tax
  }

  void setActiveStore(String storeId) {
    _activeStoreId = storeId;
    notifyListeners();
  }

  void addToCart(CartItemModel item) {
    final storeId = item.storeId ?? 'unknown_store';
    
    if (!_cartsByStore.containsKey(storeId)) {
      _cartsByStore[storeId] = [];
    }

    final storeItems = _cartsByStore[storeId]!;
    final index = storeItems.indexWhere((i) => i.id == item.id);
    
    if (index >= 0) {
      storeItems[index].quantity++;
    } else {
      storeItems.add(item);
    }
    
    _activeStoreId = storeId; // Auto-switch context to this store
    notifyListeners();
  }

  void incrementQuantity(String id, String storeId) {
    final items = _cartsByStore[storeId];
    if (items == null) return;
    
    final item = items.firstWhere((item) => item.id == id);
    item.quantity++;
    notifyListeners();
  }

  void decrementQuantity(String id, String storeId) {
    final items = _cartsByStore[storeId];
    if (items == null) return;

    final item = items.firstWhere((item) => item.id == id);
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      items.remove(item);
      if (items.isEmpty) {
        _cartsByStore.remove(storeId);
      }
    }
    notifyListeners();
  }

  void removeItem(String id, String storeId) {
    if (_cartsByStore.containsKey(storeId)) {
      _cartsByStore[storeId]!.removeWhere((item) => item.id == id);
      if (_cartsByStore[storeId]!.isEmpty) {
        _cartsByStore.remove(storeId);
      }
      notifyListeners();
    }
  }

  void addOrder(CartItemModel item, {required String paymentMethod}) {
    final randomId = "ORD-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}";
    final businessName = item.storeName ?? item.subtitle.split('\n').first;
    
    final order = OrderModel(
      id: item.id,
      orderId: randomId,
      businessName: businessName,
      productName: item.title,
      productSubtitle: item.subtitle,
      price: item.price,
      quantity: item.quantity,
      imageUrl: item.imageUrl,
      timestamp: DateTime.now(),
      paymentMethod: paymentMethod,
      status: OrderStatus.pending,
    );

    _orderedItems.insert(0, order);
    notifyListeners();
  }

  // Get list of all store IDs that have items in cart
  List<String> get activeStoreIds => _cartsByStore.keys.toList();

  get total => null;

  // Get store name for a specific store
  String getStoreName(String storeId) {
    if (_cartsByStore.containsKey(storeId) && _cartsByStore[storeId]!.isNotEmpty) {
      final item = _cartsByStore[storeId]!.first;
      return item.storeName ?? item.subtitle.split('\n').first;
    }
    return "Unknown Store";
  }

  void clearCart(String storeId) {
    _cartsByStore.remove(storeId);
    notifyListeners();
  }
}
