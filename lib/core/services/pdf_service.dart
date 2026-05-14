import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../features/crops/domain/entities/crop_entity.dart';
import '../../features/farms/domain/entities/farm_entity.dart';
import '../../features/fertilization/domain/entities/fertilization_entity.dart';
import '../../features/irrigation/domain/entities/irrigation_entity.dart';
import '../../features/labor/domain/entities/labor_entity.dart';
import '../../features/plots/domain/entities/plot_entity.dart';

class PdfService {
  static final PdfColor _primaryColor = PdfColor.fromHex('#2E7D32');
  static final PdfColor _lightGreen = PdfColor.fromHex('#E8F5E9');
  static final PdfColor _accentColor = PdfColor.fromHex('#FF8F00');
  static final PdfColor _greyColor = PdfColor.fromHex('#757575');
  static final PdfColor _darkColor = PdfColor.fromHex('#212121');

  static Future<Uint8List> generateCropReport({
    required FarmEntity farm,
    required PlotEntity plot,
    required CropEntity crop,
    required List<IrrigationEntity> irrigations,
    required List<FertilizationEntity> fertilizations,
    required List<LaborEntity> labors,
  }) async {
    final pdf = pw.Document();
    final fmt = DateFormat('dd/MM/yyyy');
    final fmtDateTime = DateFormat('dd/MM/yyyy HH:mm');
    final now = DateTime.now();

    // Calcular totales
    final totalIrrigationLiters =
        irrigations.fold<double>(0, (sum, i) => sum + (i.volumeLiters ?? 0));
    final totalFertCost =
        fertilizations.fold<double>(0, (sum, f) => sum + (f.cost ?? 0));
    final totalLaborCost =
        labors.fold<double>(0, (sum, l) => sum + (l.cost ?? 0));
    final totalCost = totalFertCost + totalLaborCost;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(farm, fmt, now),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Info del cultivo
          _buildCropInfo(crop, plot, fmt),
          pw.SizedBox(height: 20),

          // Resumen ejecutivo
          _buildSummaryCards(
            irrigations.length,
            fertilizations.length,
            labors.length,
            totalCost,
            totalIrrigationLiters,
          ),
          pw.SizedBox(height: 20),

          // Tabla de riegos
          if (irrigations.isNotEmpty) ...[
            _buildSectionTitle('💧 Registros de Riego'),
            pw.SizedBox(height: 8),
            _buildIrrigationTable(irrigations, fmtDateTime),
            pw.SizedBox(height: 20),
          ],

          // Tabla de fertilizaciones
          if (fertilizations.isNotEmpty) ...[
            _buildSectionTitle('🧪 Registros de Fertilización'),
            pw.SizedBox(height: 8),
            _buildFertilizationTable(fertilizations, fmt),
            pw.SizedBox(height: 20),
          ],

          // Tabla de labores
          if (labors.isNotEmpty) ...[
            _buildSectionTitle('👷 Registros de Labores'),
            pw.SizedBox(height: 8),
            _buildLaborTable(labors, fmt),
            pw.SizedBox(height: 20),
          ],

          // Resumen de costos
          _buildCostSummary(totalFertCost, totalLaborCost, totalCost),
        ],
      ),
    );

    return pdf.save();
  }

  // ─── Header ───────────────────────────────────────────────
  static pw.Widget _buildHeader(FarmEntity farm, DateFormat fmt, DateTime now) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _primaryColor,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      padding: const pw.EdgeInsets.all(16),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'AgroApp',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Reporte Agronómico',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 12),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                farm.name,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Generado: ${fmt.format(now)}',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Footer ───────────────────────────────────────────────
  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'AgroApp — Monitoreo inteligente de cultivos',
            style: const pw.TextStyle(color: PdfColors.grey, fontSize: 9),
          ),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(color: PdfColors.grey, fontSize: 9),
          ),
        ],
      ),
    );
  }

  // ─── Info del cultivo ─────────────────────────────────────
  static pw.Widget _buildCropInfo(
      CropEntity crop, PlotEntity plot, DateFormat fmt) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _lightGreen,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _primaryColor, width: 0.5),
      ),
      padding: const pw.EdgeInsets.all(16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${crop.cropType.toUpperCase()}${crop.variety != null ? ' — ${crop.variety}' : ''}',
            style: pw.TextStyle(
              color: _primaryColor,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              _infoItem('Parcela', plot.name),
              _infoItem('Estado', crop.status),
              _infoItem('Siembra', fmt.format(crop.plantedAt)),
              if (crop.estimatedHarvest != null)
                _infoItem('Cosecha est.', fmt.format(crop.estimatedHarvest!)),
            ],
          ),
          if (plot.areaHa != null) ...[
            pw.SizedBox(height: 8),
            pw.Row(children: [
              _infoItem('Área', '${plot.areaHa!.toStringAsFixed(1)} ha'),
              if (plot.soilType != null)
                _infoItem('Tipo de suelo', plot.soilType!),
            ]),
          ],
        ],
      ),
    );
  }

  static pw.Widget _infoItem(String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  color: _greyColor,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold)),
          pw.Text(value,
              style: pw.TextStyle(
                  color: _darkColor,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  // ─── Resumen ──────────────────────────────────────────────
  static pw.Widget _buildSummaryCards(
    int irrigationCount,
    int fertCount,
    int laborCount,
    double totalCost,
    double totalLiters,
  ) {
    return pw.Row(
      children: [
        _summaryCard('Riegos', '$irrigationCount',
            '${totalLiters.toStringAsFixed(0)} L total'),
        pw.SizedBox(width: 8),
        _summaryCard('Fertilizaciones', '$fertCount', 'aplicaciones'),
        pw.SizedBox(width: 8),
        _summaryCard('Labores', '$laborCount', 'actividades'),
        pw.SizedBox(width: 8),
        _summaryCard(
            'Costo total', 'L. ${totalCost.toStringAsFixed(2)}', 'acumulado'),
      ],
    );
  }

  static pw.Widget _summaryCard(String title, String value, String subtitle) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title,
                style: pw.TextStyle(
                    color: _greyColor,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(
                  color: _primaryColor,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.Text(subtitle,
                style: const pw.TextStyle(color: PdfColors.grey, fontSize: 8)),
          ],
        ),
      ),
    );
  }

  // ─── Título de sección ────────────────────────────────────
  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: _primaryColor,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  // ─── Tabla de Riego ───────────────────────────────────────
  static pw.Widget _buildIrrigationTable(
      List<IrrigationEntity> irrigations, DateFormat fmt) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _lightGreen),
          children: [
            _tableHeader('Fecha'),
            _tableHeader('Método'),
            _tableHeader('Volumen'),
            _tableHeader('Duración'),
          ],
        ),
        // Rows
        ...irrigations.map((i) => pw.TableRow(
              children: [
                _tableCell(fmt.format(i.appliedAt)),
                _tableCell(i.method),
                _tableCell(i.volumeLiters != null
                    ? '${i.volumeLiters!.toStringAsFixed(0)} L'
                    : '—'),
                _tableCell(
                    i.durationMin != null ? '${i.durationMin} min' : '—'),
              ],
            )),
      ],
    );
  }

  // ─── Tabla de Fertilización ───────────────────────────────
  static pw.Widget _buildFertilizationTable(
      List<FertilizationEntity> fertilizations, DateFormat fmt) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _lightGreen),
          children: [
            _tableHeader('Producto'),
            _tableHeader('Fecha'),
            _tableHeader('Tipo'),
            _tableHeader('Total kg'),
            _tableHeader('Costo'),
          ],
        ),
        ...fertilizations.map((f) => pw.TableRow(
              children: [
                _tableCell(f.productName),
                _tableCell(fmt.format(f.appliedAt)),
                _tableCell(f.productType ?? '—'),
                _tableCell(f.totalKg != null
                    ? '${f.totalKg!.toStringAsFixed(1)}'
                    : '—'),
                _tableCell(
                    f.cost != null ? 'L. ${f.cost!.toStringAsFixed(2)}' : '—'),
              ],
            )),
      ],
    );
  }

  // ─── Tabla de Labores ─────────────────────────────────────
  static pw.Widget _buildLaborTable(List<LaborEntity> labors, DateFormat fmt) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _lightGreen),
          children: [
            _tableHeader('Actividad'),
            _tableHeader('Fecha'),
            _tableHeader('Trabajadores'),
            _tableHeader('Horas'),
            _tableHeader('Costo'),
          ],
        ),
        ...labors.map((l) => pw.TableRow(
              children: [
                _tableCell(l.activityType),
                _tableCell(fmt.format(l.performedAt)),
                _tableCell('${l.workersCount}'),
                _tableCell(l.hoursWorked != null
                    ? '${l.hoursWorked!.toStringAsFixed(1)}'
                    : '—'),
                _tableCell(
                    l.cost != null ? 'L. ${l.cost!.toStringAsFixed(2)}' : '—'),
              ],
            )),
      ],
    );
  }

  // ─── Resumen de costos ────────────────────────────────────
  static pw.Widget _buildCostSummary(
      double fertCost, double laborCost, double totalCost) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _lightGreen,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _primaryColor, width: 0.5),
      ),
      padding: const pw.EdgeInsets.all(16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Resumen de Costos',
            style: pw.TextStyle(
              color: _primaryColor,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          _costRow('Fertilizantes', 'L. ${fertCost.toStringAsFixed(2)}'),
          pw.SizedBox(height: 6),
          _costRow('Mano de obra', 'L. ${laborCost.toStringAsFixed(2)}'),
          pw.Divider(color: _primaryColor),
          _costRow(
            'TOTAL',
            'L. ${totalCost.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  static pw.Widget _costRow(String label, String value, {bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            color: isBold ? _primaryColor : _darkColor,
            fontSize: isBold ? 13 : 11,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: isBold ? _primaryColor : _darkColor,
            fontSize: isBold ? 14 : 11,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // ─── Helpers de tabla ─────────────────────────────────────
  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
          color: _primaryColor,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, color: _darkColor),
      ),
    );
  }
}
