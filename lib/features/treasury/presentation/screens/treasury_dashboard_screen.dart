import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../tenant/presentation/providers/tenant_provider.dart';
import '../../domain/entities/financial_transaction.dart';
import '../providers/treasury_provider.dart';
import 'add_income_screen.dart';
import 'add_expense_screen.dart';

class TreasuryDashboardScreen extends StatelessWidget {
  const TreasuryDashboardScreen({super.key});

  void _showTransactionDetails(BuildContext context, FinancialTransaction tx) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: tx.type == TransactionType.income
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    tx.type == TransactionType.income
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: tx.type == TransactionType.income
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB91C1C),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.category,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      Text(
                        DateFormatter.formatFullDate(tx.date),
                        style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${tx.type.sign}${CurrencyFormatter.format(tx.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: tx.type == TransactionType.income
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),

            _buildDetailRow('Descripción:', tx.description),
            if (tx.donorOrRecipient != null)
              _buildDetailRow(
                tx.type == TransactionType.income ? 'Donante / Fuente:' : 'Beneficiario / Proveedor:',
                tx.donorOrRecipient!,
              ),
            _buildDetailRow('Registrado por:', tx.registeredBy),

            const SizedBox(height: 14),

            // Respaldo digital (Recibo)
            if (tx.hasReceipt) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: Color(0xFF0F172A), size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Comprobante Digital Resguardado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Foto de factura física guardada en el expediente', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 20),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tenant = context.watch<TenantProvider>();
    final treasury = context.watch<TreasuryProvider>();
    final summary = treasury.summary;
    final filteredList = treasury.filteredTransactions;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tesorería y Finanzas',
              style: theme.appBarTheme.titleTextStyle,
            ),
            Text(
              tenant.churchName,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Exportar a Excel / CSV',
            onPressed: () async {
              final exported = await treasury.exportToExcel(tenant.churchName);
              if (context.mounted && exported) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reporte financiero generado exitosamente 📊'),
                    backgroundColor: Color(0xFF15803D),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Tarjeta Principal: Saldo Actual
          CustomCard(
            padding: const EdgeInsets.all(20),
            color: tenant.primaryColor,
            border: Border.all(color: Colors.transparent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance_rounded, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'SALDO TOTAL DISPONIBLE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  summary != null ? CurrencyFormatter.format(summary.currentBalance) : '\$0.00',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Fondo general congregacional auditado',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Tarjetas de Ingresos del Mes vs Egresos del Mes
          Row(
            children: [
              // Tarjeta Ingresos
              Expanded(
                child: CustomCard(
                  padding: const EdgeInsets.all(14),
                  color: const Color(0xFFDCFCE7).withValues(alpha: isDark ? 0.2 : 0.8),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_downward_rounded, color: Color(0xFF15803D), size: 18),
                          SizedBox(width: 4),
                          Text(
                            'Ingresos Mes',
                            style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        summary != null ? CurrencyFormatter.format(summary.monthlyIncome) : '\$0.00',
                        style: const TextStyle(
                          color: Color(0xFF15803D),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Tarjeta Egresos
              Expanded(
                child: CustomCard(
                  padding: const EdgeInsets.all(14),
                  color: const Color(0xFFFEE2E2).withValues(alpha: isDark ? 0.2 : 0.8),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_upward_rounded, color: Color(0xFFB91C1C), size: 18),
                          SizedBox(width: 4),
                          Text(
                            'Egresos Mes',
                            style: TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        summary != null ? CurrencyFormatter.format(summary.monthlyExpenses) : '\$0.00',
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3. Botones de Acción (+ Ingreso, - Egreso, Exportar)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddIncomeScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('+ Ingreso'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                    );
                  },
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                  label: const Text('- Egreso'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Botón Exportar a Excel
          OutlinedButton.icon(
            onPressed: () async {
              final exported = await treasury.exportToExcel(tenant.churchName);
              if (context.mounted && exported) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reporte CSV/Excel generado y listo para compartir 📊'),
                    backgroundColor: Color(0xFF15803D),
                  ),
                );
              }
            },
            icon: const Icon(Icons.table_chart_outlined, size: 18),
            label: const Text('Exportar Historial a Excel (CSV)'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          const SizedBox(height: 20),

          // 4. Filtros de Transacciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historial de Movimientos',
                style: theme.textTheme.titleMedium,
              ),
              Row(
                children: [
                  _buildSmallFilterChip(context, 'Todos', TreasuryFilter.all),
                  const SizedBox(width: 6),
                  _buildSmallFilterChip(context, 'Ingresos', TreasuryFilter.income),
                  const SizedBox(width: 6),
                  _buildSmallFilterChip(context, 'Egresos', TreasuryFilter.expense),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 5. Lista de transacciones
          if (filteredList.isEmpty)
            const EmptyStateView(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Sin movimientos',
              description: 'No hay transacciones registradas en este filtro.',
            )
          else
            ...filteredList.map((tx) => CustomCard(
                  onTap: () => _showTransactionDetails(context, tx),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: tx.type == TransactionType.income
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          tx.type == TransactionType.income
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: tx.type == TransactionType.income
                              ? const Color(0xFF15803D)
                              : const Color(0xFFB91C1C),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.category,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Row(
                              children: [
                                Text(
                                  DateFormatter.formatShortDate(tx.date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                                if (tx.hasReceipt) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.receipt_outlined, size: 14, color: Colors.grey),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${tx.type.sign}${CurrencyFormatter.format(tx.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: tx.type == TransactionType.income
                              ? const Color(0xFF15803D)
                              : const Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                )),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSmallFilterChip(BuildContext context, String label, TreasuryFilter filter) {
    final treasury = context.watch<TreasuryProvider>();
    final isSelected = treasury.currentFilter == filter;
    final primaryColor = Theme.of(context).primaryColor;

    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: primaryColor.withValues(alpha: 0.15),
      onSelected: (_) => treasury.setFilter(filter),
    );
  }
}
