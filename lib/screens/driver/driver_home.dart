import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/firebase_service.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});
  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();
    final service = context.read<FirebaseService>();
    final driverId = auth.user?.uid ?? '';
    return StreamBuilder<Driver?>(stream: service.streamDriver(driverId), builder: (ctx, driverSnap) {
      final driver = driverSnap.data;
      return Scaffold(
        appBar: AppBar(title: Text('مرحباً ${auth.user?.name ?? ""}'), actions: [
          if (driver != null) Switch(value: driver.isOnline, onChanged: (v) => service.setDriverOnline(driverId, v), activeColor: Colors.greenAccent),
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            if (driver != null) await service.setDriverOnline(driverId, false);
            await auth.logout();
            if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
          }),
        ]),
        body: StreamBuilder<List<Order>>(stream: service.streamDriverOrders(driverId), builder: (ctx2, snap) {
          if (!snap.hasData) return const AppLoading();
          final orders = snap.data!.where((o) => o.status.isActive).toList();
          if (orders.isEmpty) return const AppEmpty(emoji: '📦', title: 'لا توجد طلبات نشطة', subtitle: 'تأكد أنك متصل لاستقبال الطلبات');
          return ListView.builder(padding: const EdgeInsets.all(12), itemCount: orders.length, itemBuilder: (_, i) {
            final o = orders[i];
            return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Text('#${o.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(), StatusBadge(label: o.status.label, color: o.status.color)]),
                InfoRow(icon: Icons.restaurant, text: o.restaurantName),
                InfoRow(icon: Icons.person, text: '${o.customerName} — ${o.customerPhone}'),
                InfoRow(icon: Icons.location_on, text: o.deliveryAddress),
                const Divider(),
                Text(formatCurrency(o.grandTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                if (o.status == OrderStatus.outForDelivery)
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    onPressed: () async {
                      await service.markOrderDelivered(o.id, o.driverId ?? '');
                      if (context.mounted) showSuccess(context, 'تم التوصيل! +10 ر.س أرباح');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    child: const Text('تأكيد التوصيل'))),
              ])));
          });
        }),
      );
    });
  }
}
