import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:your_money/app/modules/Dompet/controllers/dompet_controller.dart';

class AddDompetView extends StatefulWidget {
  const AddDompetView({
    super.key,
    this.isEdit = false,
    this.editIndex,
    this.initialItem,
  });

  final bool isEdit;
  final int? editIndex;
  final WalletItem? initialItem;

  @override
  State<AddDompetView> createState() => _AddDompetViewState();
}

class _AddDompetViewState extends State<AddDompetView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _saldoCtrl = TextEditingController();

  bool _isFormatting = false;

  String _selectedType = 'tunai';
  String _selectedIcon = 'cash';

  static const _blue = Color(0xFF1E88E5);
  static const _fieldBg = Color(0xFFF8F8F8);
  static const _border = Color(0xFFE5E5E5);

  @override
  void dispose() {
    _saldoCtrl.removeListener(_handleSaldoChange);
    _nameCtrl.dispose();
    _saldoCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _saldoCtrl.text = '0';
    _saldoCtrl.addListener(_handleSaldoChange);

    // Prefill for EDIT mode
    final item = widget.initialItem;
    if (widget.isEdit && item != null) {
      _nameCtrl.text = item.name;
      _selectedType = item.type;
      _selectedIcon = item.iconKey;
      _saldoCtrl.removeListener(_handleSaldoChange);
      _saldoCtrl.text = _formatInt(item.saldo);
      _saldoCtrl.addListener(_handleSaldoChange);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DompetController c = Get.find<DompetController>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Dompet' : 'Tambah Dompet'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            physics: const BouncingScrollPhysics(),
            children: [
              _card(
                children: [
                  const Text(
                    'Nama Dompet',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  _textField(
                    controller: _nameCtrl,
                    hint: 'Masukkan nama dompet',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tipe Dompet',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  _typePicker(),
                  const SizedBox(height: 16),
                  const Text(
                    'Saldo Awal',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  _textField(
                    controller: _saldoCtrl,
                    hint: 'Rp 0',
                    prefix: 'Rp ',
                    keyboard: TextInputType.number,
                    digitsOnly: true,
                    onTap: () {
                      if (_saldoCtrl.text == '0') {
                        _saldoCtrl.clear();
                      }
                    },
                    onSubmitted: (_) => _ensureSaldoNotEmpty(),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Wajib diisi';
                      }
                      final parsed = int.tryParse(v.replaceAll('.', ''));
                      if (parsed == null) return 'Masukkan angka yang valid';
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _card(
                children: [
                  const Text(
                    'Pilih Ikon',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _iconChoice('cash', Icons.payments_rounded),
                      const SizedBox(width: 10),
                      _iconChoice(
                          'wallet', Icons.account_balance_wallet_rounded),
                      const SizedBox(width: 10),
                      _iconChoice('card', Icons.credit_card_rounded),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() != true) return;
                    final saldo =
                        int.tryParse(_saldoCtrl.text.replaceAll('.', '')) ?? 0;
                    if (widget.isEdit && widget.editIndex != null) {
                      c.updateWallet(
                        widget.editIndex!,
                        name: _nameCtrl.text.trim(),
                        type: _selectedType,
                        iconKey: _selectedIcon,
                        saldo: saldo,
                      );
                    } else {
                      c.addWallet(
                        name: _nameCtrl.text.trim(),
                        type: _selectedType,
                        iconKey: _selectedIcon,
                        saldo: saldo,
                      );
                    }
                    Get.back();
                  },
                  child: Text(
                    widget.isEdit ? 'Update Dompet' : 'Simpan Dompet',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    TextInputType keyboard = TextInputType.text,
    bool digitsOnly = false,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      onTap: onTap,
      onFieldSubmitted: onSubmitted,
      inputFormatters:
          digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: _fieldBg,
        prefixText: prefix,
        prefixStyle:
            const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        hintStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          color: Colors.black45,
        ),
      ),
      validator: validator,
    );
  }

  void _handleSaldoChange() {
    if (_isFormatting) return;
    _isFormatting = true;

    final raw = _saldoCtrl.text.replaceAll('.', '');
    if (raw.isEmpty) {
      _saldoCtrl.text = '0';
      _saldoCtrl.selection =
          TextSelection.collapsed(offset: _saldoCtrl.text.length);
      _isFormatting = false;
      return;
    }

    final value = int.tryParse(raw) ?? 0;
    final formatted = _formatInt(value);
    _saldoCtrl.text = formatted;
    _saldoCtrl.selection =
        TextSelection.collapsed(offset: _saldoCtrl.text.length);
    _isFormatting = false;
  }

  String _formatInt(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final reverseIndex = s.length - i - 1;
      buffer.write(s[i]);
      if (reverseIndex % 3 == 0 && i != s.length - 1) buffer.write('.');
    }
    return buffer.toString();
  }

  void _ensureSaldoNotEmpty() {
    if (_saldoCtrl.text.isEmpty) {
      _saldoCtrl.text = '0';
      _saldoCtrl.selection =
          TextSelection.collapsed(offset: _saldoCtrl.text.length);
    }
  }

  Widget _dropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return const SizedBox.shrink();
  }

  Widget _typePicker() {
    final label = _selectedType == 'tunai'
        ? 'Tunai'
        : _selectedType == 'rekening bank'
            ? 'Rekening Bank'
            : 'E-Wallet';
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: _showTypeSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _fieldBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.black87)),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.black54),
          ],
        ),
      ),
    );
  }

  void _showTypeSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _typeTile('tunai', 'Tunai'),
              _typeTile('rekening bank', 'Rekening Bank'),
              _typeTile('e-wallet', 'E-Wallet'),
            ],
          ),
        );
      },
    );
  }

  Widget _typeTile(String value, String label) {
    final active = _selectedType == value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: active ? const Icon(Icons.check_circle, color: _blue) : null,
      onTap: () {
        setState(() => _selectedType = value);
        Navigator.pop(context);
      },
    );
  }

  Widget _iconChoice(String key, IconData icon) {
    final bool active = _selectedIcon == key;
    return InkWell(
      onTap: () => setState(() => _selectedIcon = key),
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? _blue.withOpacity(0.12) : Colors.white,
          border: Border.all(
            color: active ? _blue : _border,
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 22,
          color: active ? _blue : Colors.black54,
        ),
      ),
    );
  }
}
