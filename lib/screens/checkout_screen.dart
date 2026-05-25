import 'package:flutter/material.dart';
import '../widgets/product_image.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';
import '../core/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentMethod = 0; // 0 for Credit Card, 1 for COD

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to safely read the provider after initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressProvider = context.read<AddressProvider>();
      final defaultAddress = addressProvider.defaultAddress;
      
      if (defaultAddress != null) {
        _firstNameController.text = defaultAddress['firstName'] ?? '';
        _lastNameController.text = defaultAddress['lastName'] ?? '';
        _addressLine1Controller.text = defaultAddress['addressLine1'] ?? '';
        _cityController.text = defaultAddress['city'] ?? '';
        _postalCodeController.text = defaultAddress['postalCode'] ?? '';
        _phoneNumberController.text = defaultAddress['phoneNumber'] ?? '';
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      appBar: AppBar(
        backgroundColor: NoorTheme.appBarBg(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'NOOR FASHION',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
                color: NoorTheme.textColor(context),
              ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: NoorTheme.textColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Row(
            children: [
              Icon(Icons.lock, size: 14, color: NoorTheme.textColor(context).withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Text(
                'SECURE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: NoorTheme.textColor(context),
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, '01', 'SHIPPING ADDRESS'),
            const SizedBox(height: 25),
            _buildShippingForm(context),
            const SizedBox(height: 50),
            _buildSectionHeader(context, '02', 'PAYMENT METHOD'),
            const SizedBox(height: 25),
            _buildPaymentMethods(context),
            const SizedBox(height: 50),
            _buildOrderSummary(context, cart),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: ElevatedButton(
          onPressed: () async {
            if (_firstNameController.text.trim().isEmpty ||
                _lastNameController.text.trim().isEmpty ||
                _addressLine1Controller.text.trim().isEmpty ||
                _cityController.text.trim().isEmpty ||
                _postalCodeController.text.trim().isEmpty ||
                _phoneNumberController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in all shipping address fields.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              await FirestoreService().placeOrder(
                userId: user.uid,
                items: cart.items.map((item) => {
                  'productId': item.product.id,
                  'name': item.product.name,
                  'description': item.product.description,
                  'price': item.product.price,
                  'imageUrl': item.product.imageUrl,
                  'category': item.product.category,
                  'quantity': item.quantity,
                }).toList(),
                totalAmount: cart.totalAmount + 450 + (cart.totalAmount * 0.08),
                subtotal: cart.totalAmount,
                shippingFee: 450.0,
                tax: cart.totalAmount * 0.08,
                shippingAddress: {
                  'firstName': _firstNameController.text.trim(),
                  'lastName': _lastNameController.text.trim(),
                  'address': _addressLine1Controller.text.trim(),
                  'city': _cityController.text.trim(),
                  'postalCode': _postalCodeController.text.trim(),
                  'phoneNumber': _phoneNumberController.text.trim(),
                },
                paymentMethod: _selectedPaymentMethod == 0 ? 'Credit Card' : 'Cash on Delivery',
              );
            }
            
            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Order placed successfully!'),
                backgroundColor: NoorTheme.textColor(context),
              ),
            );
            context.read<CartProvider>().clear(); // Clear cart items locally
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: NoorTheme.textColor(context),
            foregroundColor: NoorTheme.isDark(context) ? NoorTheme.surfaceDark : Colors.white,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 18),
              SizedBox(width: 8),
              Text('PLACE ORDER', style: TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.w900, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String index, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: NoorTheme.textColor(context),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            index,
            style: TextStyle(color: NoorTheme.isDark(context) ? NoorTheme.surfaceDark : Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: NoorTheme.textColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildShippingForm(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildInputField(context, 'FIRST NAME', 'Aman', _firstNameController)),
            const SizedBox(width: 15),
            Expanded(child: _buildInputField(context, 'LAST NAME', 'Perera', _lastNameController)),
          ],
        ),
        const SizedBox(height: 20),
        _buildInputField(context, 'ADDRESS LINE 1', '45 Victoria Place', _addressLine1Controller),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildInputField(context, 'CITY', 'Colombo', _cityController)),
            const SizedBox(width: 15),
            Expanded(child: _buildInputField(context, 'POSTAL CODE', '00700', _postalCodeController)),
          ],
        ),
        const SizedBox(height: 20),
        _buildInputField(context, 'PHONE NUMBER', '+94 77 123 4567', _phoneNumberController),
      ],
    );
  }

  Widget _buildInputField(BuildContext context, String label, String placeholder, [TextEditingController? controller]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: NoorTheme.textMuted(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: NoorTheme.inputBg(context), // surface-container
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: NoorTheme.textColor(context)),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: NoorTheme.textMuted(context)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildPaymentOption(context, 0, 'CREDIT CARD', Icons.credit_card)),
            const SizedBox(width: 15),
            Expanded(child: _buildPaymentOption(context, 1, 'CASH ON DELIVERY', Icons.payments_outlined)),
          ],
        ),
        if (_selectedPaymentMethod == 0) ...[
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: NoorTheme.cardColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NoorTheme.border(context)),
            ),
            child: Column(
              children: [
                _buildInputField(context, 'CARD NUMBER', '0000 0000 0000 0000'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildInputField(context, 'EXPIRY DATE', 'MM/YY')),
                    const SizedBox(width: 15),
                    Expanded(child: _buildInputField(context, 'CVV', '***')),
                  ],
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildPaymentOption(BuildContext context, int value, String title, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? NoorTheme.cardColor(context) : NoorTheme.cardAlt(context), // surface-container-low
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? NoorTheme.textColor(context) : NoorTheme.border(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 28, color: NoorTheme.textColor(context)),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? NoorTheme.textColor(context) : NoorTheme.border(context), width: 2),
                    color: isSelected ? NoorTheme.textColor(context) : Colors.transparent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: NoorTheme.textColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(30),
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
          const SizedBox(height: 25),
          ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 80,
                      child: ProductImage(imageUrl: item.product.imageUrl),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NoorTheme.textColor(context)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Size: M | Qty: ${item.quantity}',
                            style: TextStyle(fontSize: 10, color: NoorTheme.textMuted(context)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'LKR ${(item.product.price * item.quantity).toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NoorTheme.textColor(context)),
                    ),
                  ],
                ),
              )),
          Divider(height: 40, color: NoorTheme.border(context)),
          _buildSummaryRow(context, 'Subtotal', cart.totalAmount),
          const SizedBox(height: 10),
          _buildSummaryRow(context, 'Shipping', 450),
          const SizedBox(height: 10),
          _buildSummaryRow(context, 'Tax (VAT 8%)', cart.totalAmount * 0.08),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: NoorTheme.textColor(context))),
              Text(
                'LKR ${(cart.totalAmount + 450 + (cart.totalAmount * 0.08)).toStringAsFixed(0)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: NoorTheme.textColor(context)),
              ),
            ],
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
