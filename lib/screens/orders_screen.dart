import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../services/firestore_service.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: NoorTheme.background(context),
        appBar: _buildAppBar(context),
        body: Center(
          child: Text('Please log in to view your orders.', style: TextStyle(color: NoorTheme.textColor(context))),
        ),
      );
    }

    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      appBar: _buildAppBar(context),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getOrdersStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: NoorTheme.textColor(context)),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildOrderCard(context, orders[index]);
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: NoorTheme.appBarBg(context),
      elevation: 0,
      centerTitle: true,
      title: Text(
        'MY ORDERS',
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
          color: NoorTheme.textColor(context),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: NoorTheme.textColor(context)),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: NoorTheme.textColor(context).withValues(alpha: 0.1),
          ),
          const SizedBox(height: 24),
          Text(
            'NO ORDERS YET',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: NoorTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your purchase history will appear here.',
            style: TextStyle(
              color: NoorTheme.textMuted(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    final timestamp = order['createdAt'] as Timestamp?;
    final date = timestamp != null
        ? DateFormat('MMM dd, yyyy').format(timestamp.toDate())
        : 'Unknown Date';
    final total = (order['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final status = order['status'] ?? 'Processing';
    final orderId = order['orderId'] ?? '';
    final items = order['items'] as List<dynamic>? ?? [];

    final cardContent = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NoorTheme.cardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NoorTheme.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ORDER #${orderId.toString().length > 6 ? orderId.toString().substring(0, 6).toUpperCase() : orderId}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: NoorTheme.textColor(context),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'Processing' ? NoorTheme.iconBg(context) : NoorTheme.textColor(context),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: status == 'Processing' ? NoorTheme.textColor(context) : NoorTheme.background(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: NoorTheme.textMuted(context),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: NoorTheme.border(context)),
          const SizedBox(height: 16),
          Text(
            '${items.length} ITEM(S)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: NoorTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total: LKR ${total.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: NoorTheme.textColor(context),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      child: cardContent,
    );
  }
}
