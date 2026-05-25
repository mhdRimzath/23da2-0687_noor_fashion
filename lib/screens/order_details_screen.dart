import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../widgets/product_image.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final orderId = order['orderId'] ?? 'UNKNOWN';
    final shortOrderId = orderId.toString().length > 6 ? orderId.toString().substring(0, 6).toUpperCase() : orderId;
    final timestamp = order['createdAt'] as Timestamp?;
    final date = timestamp != null
        ? DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate())
        : 'Unknown Date';
    final status = order['status'] ?? 'Processing';
    
    final items = order['items'] as List<dynamic>? ?? [];
    
    // Safely extract financial data with fallbacks for older orders
    final totalAmount = (order['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final subtotal = (order['subtotal'] as num?)?.toDouble() ?? totalAmount;
    final shippingFee = (order['shippingFee'] as num?)?.toDouble() ?? 0.0;
    final tax = (order['tax'] as num?)?.toDouble() ?? 0.0;
    
    final shippingAddress = order['shippingAddress'] as Map<String, dynamic>? ?? {};
    final paymentMethod = order['paymentMethod'] ?? 'Unknown Payment';

    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      appBar: AppBar(
        backgroundColor: NoorTheme.appBarBg(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'ORDER #$shortOrderId',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: NoorTheme.cardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: NoorTheme.border(context)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDER PLACED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: NoorTheme.textMuted(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: NoorTheme.textColor(context),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: status == 'Processing' ? NoorTheme.cardAlt(context) : NoorTheme.textColor(context),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: status == 'Processing' ? NoorTheme.textColor(context) : (NoorTheme.isDark(context) ? NoorTheme.surfaceDark : Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Items Section
            Text(
              'ITEMS ORDERED',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: NoorTheme.textColor(context),
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => _buildOrderItem(context, item)),
            
            const SizedBox(height: 32),
            
            // Address & Payment Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildInfoCard(
                    context: context,
                    title: 'SHIPPING ADDRESS',
                    content: '${shippingAddress['firstName'] ?? ''} ${shippingAddress['lastName'] ?? ''}\n'
                             '${shippingAddress['address'] ?? ''}\n'
                             '${shippingAddress['city'] ?? ''}, ${shippingAddress['postalCode'] ?? ''}',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    context: context,
                    title: 'PAYMENT METHOD',
                    content: paymentMethod,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Financial Summary
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: NoorTheme.cardAlt(context), // surface-container-low
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORDER SUMMARY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: NoorTheme.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSummaryRow(context, 'Subtotal', subtotal),
                  const SizedBox(height: 12),
                  _buildSummaryRow(context, 'Shipping', shippingFee),
                  const SizedBox(height: 12),
                  _buildSummaryRow(context, 'Tax', tax),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: NoorTheme.border(context)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: NoorTheme.textColor(context))),
                      Text(
                        'LKR ${totalAmount.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: NoorTheme.textColor(context)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, dynamic item) {
    final name = item['name'] ?? 'Unknown Item';
    final category = item['category'] ?? 'Category';
    final price = (item['price'] as num?)?.toDouble() ?? 0.0;
    final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
    final imageUrl = item['imageUrl'] ?? 'assets/images/static_23.jpg';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NoorTheme.cardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NoorTheme.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 90,
              decoration: BoxDecoration(
                color: NoorTheme.cardAlt(context),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: ProductImage(imageUrl: imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: NoorTheme.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.toUpperCase()} | QTY: $quantity',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: NoorTheme.textMuted(context),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'LKR ${(price * quantity).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: NoorTheme.textColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required BuildContext context, required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NoorTheme.cardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NoorTheme.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: NoorTheme.textMuted(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: NoorTheme.textColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: NoorTheme.textMuted(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'LKR ${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: NoorTheme.textColor(context),
          ),
        ),
      ],
    );
  }
}
