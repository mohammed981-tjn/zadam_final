import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../models/models.dart';
import '../../providers/firebase_service.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common_widgets.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final service = context.read<FirebaseService>();
    final uid = context.read<app_auth.AuthProvider>().user?.uid ?? '';
    return StreamBuilder<List<Order>>(stream: service.streamCustomerOrders(uid), builder: (ctx, snap) {
      if (!snap.hasData) return const AppLoading();
      final orders = snap.data!;
      if (orders.isEmpty) return const AppEmpty(emoji: '📋', title: 'لا يوجد طلبات');
      return ListView.builder(padding: const EdgeInsets.all(12), itemCount: orders.length, itemBuilder: (_, i) {
        final o = orders[i];
        return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Text('#${o.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(), StatusBadge(label: o.status.label, color: o.status.color, icon: o.status.icon)]),
            InfoRow(icon: Icons.restaurant, text: o.restaurantName),
            InfoRow(icon: Icons.access_time, text: '${o.createdAt.day}/${o.createdAt.month} ${o.createdAt.hour}:${o.createdAt.minute.toString().padLeft(2, '0')}'),
            const Divider(),
            Text(formatCurrency(o.grandTotal), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            if (o.status == OrderStatus.delivered && !o.isRated)
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () => _showRateDialog(context, service, o),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                child: const Text('قيّم الطلب'))),
          ])));
      });
    });
  }

  void _showRateDialog(BuildContext context, FirebaseService service, Order o) {
    double orderRating = 5, driverRating = 5;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx2, setState) => AlertDialog(
      title: const Text('قيّم تجربتك'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('جودة الطلب'),
        RatingBar.builder(initialRating: 5, itemCount: 5, itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (r) => orderRating = r),
        const SizedBox(height: 12),
        const Text('أداء السائق'),
        RatingBar.builder(initialRating: 5, itemCount: 5, itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (r) => driverRating = r),
      ]),
      actions: [
        ElevatedButton(onPressed: () async {
          await service.rateOrder(orderId: o.id, driverId: o.driverId ?? '', orderRating: orderRating, driverRating: driverRating);
          if (context.mounted) Navigator.pop(ctx);
        }, child: const Text('إرسال')),
      ],
    )));
  }
}
