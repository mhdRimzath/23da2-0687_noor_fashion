import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/address_provider.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  void _showAddAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddAddressSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();

    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      appBar: AppBar(
        backgroundColor: NoorTheme.appBarBg(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'SAVED ADDRESSES',
          style: TextStyle(
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
      body: addressProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: NoorTheme.textColor(context)))
          : addressProvider.addresses.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  padding: const EdgeInsets.all(25),
                  itemCount: addressProvider.addresses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final address = addressProvider.addresses[index];
                    return _buildAddressCard(context, address, addressProvider);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAddressSheet(context),
        backgroundColor: NoorTheme.textColor(context),
        foregroundColor: NoorTheme.isDark(context) ? NoorTheme.surfaceDark : Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on_outlined, size: 80, color: NoorTheme.textColor(context).withValues(alpha: 0.2)),
          const SizedBox(height: 20),
          Text(
            'NO SAVED ADDRESSES',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: NoorTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add an address for faster checkout.',
            style: TextStyle(
              fontSize: 12,
              color: NoorTheme.textMuted(context),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _showAddAddressSheet(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text('ADD ADDRESS', style: TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Map<String, dynamic> address, AddressProvider provider) {
    final isDefault = address['isDefault'] == true;
    final addressId = address['id'] as String;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDefault ? NoorTheme.cardColor(context) : NoorTheme.cardAlt(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefault ? NoorTheme.textColor(context) : NoorTheme.border(context),
          width: isDefault ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: isDefault ? NoorTheme.textColor(context) : NoorTheme.textMuted(context)),
                  const SizedBox(width: 10),
                  Text(
                    '${address['firstName']} ${address['lastName']}'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: NoorTheme.textColor(context),
                    ),
                  ),
                ],
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: NoorTheme.accentGold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'DEFAULT',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: NoorTheme.isDark(context) ? NoorTheme.surfaceDark : NoorTheme.primaryNavy,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Text(address['addressLine1'] ?? '', style: TextStyle(fontSize: 12, color: NoorTheme.textMuted(context))),
          const SizedBox(height: 5),
          Text('${address['city'] ?? ''}, ${address['postalCode'] ?? ''}', style: TextStyle(fontSize: 12, color: NoorTheme.textMuted(context))),
          const SizedBox(height: 5),
          Text(address['phoneNumber'] ?? '', style: TextStyle(fontSize: 12, color: NoorTheme.textMuted(context))),
          const SizedBox(height: 20),
          Row(
            children: [
              if (!isDefault)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => provider.setDefaultAddress(addressId),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: NoorTheme.textColor(context),
                      side: BorderSide(color: NoorTheme.border(context)),
                    ),
                    child: const Text('SET AS DEFAULT', style: TextStyle(fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.bold)),
                  ),
                ),
              if (!isDefault) const SizedBox(width: 15),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => provider.deleteAddress(addressId),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.redAccent),
                    foregroundColor: Colors.redAccent,
                  ),
                  child: const Text('DELETE', style: TextStyle(fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddAddressSheet extends StatefulWidget {
  const _AddAddressSheet();

  @override
  State<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<_AddAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _isDefault = false;

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

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final addressData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'addressLine1': _addressLine1Controller.text.trim(),
        'city': _cityController.text.trim(),
        'postalCode': _postalCodeController.text.trim(),
        'phoneNumber': _phoneNumberController.text.trim(),
        'isDefault': _isDefault,
      };
      context.read<AddressProvider>().addAddress(addressData);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NoorTheme.cardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 25, right: 25, top: 30,
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ADD NEW ADDRESS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: NoorTheme.textColor(context))),
                  IconButton(icon: Icon(Icons.close, color: NoorTheme.textColor(context)), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 25),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Switch(
                    value: _isDefault,
                    onChanged: (value) => setState(() => _isDefault = value),
                    activeThumbColor: NoorTheme.isDark(context) ? NoorTheme.accentGold : NoorTheme.primaryNavy,
                  ),
                  const SizedBox(width: 10),
                  Text('Set as default shipping address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: NoorTheme.textMuted(context))),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
                child: const Text('SAVE ADDRESS', style: TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context, String label, String placeholder, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: NoorTheme.textMuted(context))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: NoorTheme.inputBg(context), borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            controller: controller,
            style: TextStyle(color: NoorTheme.textColor(context)),
            validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: NoorTheme.textMuted(context)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              errorStyle: const TextStyle(height: 0),
            ),
          ),
        ),
      ],
    );
  }
}
