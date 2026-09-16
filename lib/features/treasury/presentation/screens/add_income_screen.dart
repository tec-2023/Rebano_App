import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../tenant/presentation/providers/tenant_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/treasury_provider.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _donorController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _incomeCategories = [
    'Diezmos Congregacionales',
    'Ofrenda General',
    'Fondo Pro-Templo',
    'Misiones y Evangelismo',
    'Ofrenda de Células Hogareñas',
    'Actividad Especial Pro-Fondos',
  ];

  late String _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _incomeCategories.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _donorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final tenant = context.read<TenantProvider>();
    final auth = context.read<AuthProvider>();
    final treasury = context.read<TreasuryProvider>();

    final success = await treasury.registerIncome(
      churchId: tenant.currentTenant.id,
      category: _selectedCategory,
      amount: double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0,
      date: _selectedDate,
      donor: _donorController.text.trim().isNotEmpty ? _donorController.text.trim() : null,
      description: _descriptionController.text.trim(),
      registeredBy: auth.currentUser?.name ?? 'Tesorero',
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Ingreso registrado correctamente en tesorería! 💵'),
            backgroundColor: Color(0xFF15803D),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Ingreso'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Entrada de Fondos',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Registra diezmos, ofrendas o donaciones recibidas para el fondo de la iglesia.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Selector de Categoría
                const Text(
                  'Categoría del Ingreso',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(),
                  items: _incomeCategories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 14)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 16),

                // Monto
                CustomTextField(
                  controller: _amountController,
                  label: 'Monto Recibido (C\$ Córdobas)',
                  hint: '0.00',
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || double.tryParse(val.replaceAll(',', '')) == null || double.parse(val) <= 0) {
                      return 'Ingresa un monto numérico válido mayor a 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Donante / Fuente Opcional
                CustomTextField(
                  controller: _donorController,
                  label: 'Donante o Fuente (Opcional)',
                  hint: 'Ej. Hno. Juan Silva / Culto de Jóvenes / Anónimo',
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Fecha (Protegida contra overflow)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fecha de Recepción', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 22, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                DateFormatter.formatFullDate(_selectedDate),
                                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Descripción
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Descripción o Detalle',
                  hint: 'Ej. Ofrenda dominical servicio de la mañana...',
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Ingresa una breve descripción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                AppButton(
                  text: 'Guardar Ingreso',
                  onPressed: _handleSubmit,
                  isLoading: _isLoading,
                  customColor: const Color(0xFF15803D),
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
