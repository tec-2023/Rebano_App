import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/cell_provider.dart';

class CellReportScreen extends StatefulWidget {
  const CellReportScreen({super.key});

  @override
  State<CellReportScreen> createState() => _CellReportScreenState();
}

class _CellReportScreenState extends State<CellReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _attendanceController = TextEditingController(text: '7');
  final _visitorsController = TextEditingController(text: '2');
  final _tractsController = TextEditingController(text: '35');
  final _offeringController = TextEditingController(text: '250.00');
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _attendanceController.dispose();
    _visitorsController.dispose();
    _tractsController.dispose();
    _offeringController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final cell = context.read<CellProvider>();

    final success = await cell.submitReport(
      attendanceCount: int.tryParse(_attendanceController.text) ?? 0,
      newVisitorsCount: int.tryParse(_visitorsController.text) ?? 0,
      tractsDeliveredCount: int.tryParse(_tractsController.text) ?? 0,
      offeringAmount: double.tryParse(_offeringController.text) ?? 0.0,
      notes: _notesController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reporte de célula enviado exitosamente al pastorado! 📊'),
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
        title: const Text('Reporte de Célula'),
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
                  'Estadísticas de la Reunión',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Ingresa los resultados del miniculto y jornada de evangelismo semanal para el control pastoral.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Asistencia total
                CustomTextField(
                  controller: _attendanceController,
                  label: 'Total de Hermanos Asistentes',
                  hint: '0',
                  prefixIcon: Icons.people_alt_outlined,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || int.tryParse(val) == null) {
                      return 'Ingresa una cantidad válida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Visitas nuevas
                CustomTextField(
                  controller: _visitorsController,
                  label: 'Nuevas Visitas / Amigos Invitados',
                  hint: '0',
                  prefixIcon: Icons.person_add_alt_1_outlined,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || int.tryParse(val) == null) {
                      return 'Ingresa una cantidad';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tratados entregados
                CustomTextField(
                  controller: _tractsController,
                  label: 'Tratados / Folletos Evangelísticos Entregados',
                  hint: '0',
                  prefixIcon: Icons.menu_book_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Ofrenda recogida
                CustomTextField(
                  controller: _offeringController,
                  label: 'Ofrenda Recogida (\$ MXN)',
                  hint: '0.00',
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),

                // Notas y testimonios
                CustomTextField(
                  controller: _notesController,
                  label: 'Observaciones, Testimonios y Peticiones Especiales',
                  hint: 'Ej. Dos personas hicieron profesión de fe, se ministró por sanidad...',
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 28),

                AppButton(
                  text: 'Enviar Reporte al Pastor',
                  onPressed: _handleSubmitReport,
                  isLoading: _isSubmitting,
                  icon: Icons.send_rounded,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
