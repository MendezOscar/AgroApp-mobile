import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../../features/crops/domain/entities/crop_entity.dart';
import '../../features/farms/domain/entities/farm_entity.dart';
import '../../features/fertilization/domain/entities/fertilization_entity.dart';
import '../../features/irrigation/domain/entities/irrigation_entity.dart';
import '../../features/labor/domain/entities/labor_entity.dart';
import '../../features/plots/domain/entities/plot_entity.dart';

class ExcelService {
  static final _headerStyle = CellStyle(bold: true);

  static Future<List<int>> generateCropReport({
    required FarmEntity farm,
    required PlotEntity plot,
    required CropEntity crop,
    required List<IrrigationEntity> irrigations,
    required List<FertilizationEntity> fertilizations,
    required List<LaborEntity> labors,
  }) async {
    final fmt = DateFormat('dd/MM/yyyy');
    final excel = Excel.createExcel();

    final totalIrrigationLiters =
        irrigations.fold<double>(0, (sum, i) => sum + (i.volumeLiters ?? 0));
    final totalFertCost =
        fertilizations.fold<double>(0, (sum, f) => sum + (f.cost ?? 0));
    final totalLaborCost =
        labors.fold<double>(0, (sum, l) => sum + (l.cost ?? 0));
    final totalCost = totalFertCost + totalLaborCost;

    _buildSummarySheet(
      excel,
      farm: farm,
      plot: plot,
      crop: crop,
      fmt: fmt,
      irrigationCount: irrigations.length,
      fertCount: fertilizations.length,
      laborCount: labors.length,
      totalIrrigationLiters: totalIrrigationLiters,
      totalFertCost: totalFertCost,
      totalLaborCost: totalLaborCost,
      totalCost: totalCost,
    );
    _buildIrrigationSheet(excel, irrigations, fmt);
    _buildFertilizationSheet(excel, fertilizations, fmt);
    _buildLaborSheet(excel, labors, fmt);

    excel.delete('Sheet1');

    return excel.save() ?? [];
  }

  static void _appendHeader(Sheet sheet, List<String> headers) {
    final row = headers.map((h) => TextCellValue(h)).toList();
    sheet.appendRow(row);
    final lastRowIndex = sheet.maxRows - 1;
    for (var col = 0; col < headers.length; col++) {
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: col, rowIndex: lastRowIndex))
          .cellStyle = _headerStyle;
    }
  }

  static void _buildSummarySheet(
    Excel excel, {
    required FarmEntity farm,
    required PlotEntity plot,
    required CropEntity crop,
    required DateFormat fmt,
    required int irrigationCount,
    required int fertCount,
    required int laborCount,
    required double totalIrrigationLiters,
    required double totalFertCost,
    required double totalLaborCost,
    required double totalCost,
  }) {
    final sheet = excel['Resumen'];

    void addRow(String label, String value) {
      sheet.appendRow([TextCellValue(label), TextCellValue(value)]);
    }

    addRow('Finca', farm.name);
    addRow('Parcela', plot.name);
    addRow('Cultivo',
        '${crop.cropType}${crop.variety != null ? ' — ${crop.variety}' : ''}');
    addRow('Estado', crop.status);
    addRow('Siembra', fmt.format(crop.plantedAt));
    if (crop.estimatedHarvest != null) {
      addRow('Cosecha estimada', fmt.format(crop.estimatedHarvest!));
    }
    if (plot.areaHa != null) {
      addRow('Área', '${plot.areaHa!.toStringAsFixed(1)} ha');
    }
    if (plot.soilType != null) {
      addRow('Tipo de suelo', plot.soilType!);
    }
    sheet.appendRow([]);
    addRow('Riegos', '$irrigationCount (${totalIrrigationLiters.toStringAsFixed(0)} L total)');
    addRow('Fertilizaciones', '$fertCount');
    addRow('Labores', '$laborCount');
    sheet.appendRow([]);
    addRow('Costo fertilizantes', 'L. ${totalFertCost.toStringAsFixed(2)}');
    addRow('Costo mano de obra', 'L. ${totalLaborCost.toStringAsFixed(2)}');
    addRow('Costo total', 'L. ${totalCost.toStringAsFixed(2)}');
  }

  static void _buildIrrigationSheet(
      Excel excel, List<IrrigationEntity> irrigations, DateFormat fmt) {
    final sheet = excel['Riego'];
    _appendHeader(sheet, ['Fecha', 'Método', 'Volumen (L)', 'Duración (min)']);
    for (final i in irrigations) {
      sheet.appendRow([
        TextCellValue(fmt.format(i.appliedAt)),
        TextCellValue(i.method),
        i.volumeLiters != null
            ? DoubleCellValue(i.volumeLiters!)
            : TextCellValue('—'),
        i.durationMin != null
            ? IntCellValue(i.durationMin!)
            : TextCellValue('—'),
      ]);
    }
  }

  static void _buildFertilizationSheet(Excel excel,
      List<FertilizationEntity> fertilizations, DateFormat fmt) {
    final sheet = excel['Fertilización'];
    _appendHeader(
        sheet, ['Producto', 'Fecha', 'Tipo', 'Total kg', 'Costo']);
    for (final f in fertilizations) {
      sheet.appendRow([
        TextCellValue(f.productName),
        TextCellValue(fmt.format(f.appliedAt)),
        TextCellValue(f.productType ?? '—'),
        f.totalKg != null ? DoubleCellValue(f.totalKg!) : TextCellValue('—'),
        f.cost != null ? DoubleCellValue(f.cost!) : TextCellValue('—'),
      ]);
    }
  }

  static void _buildLaborSheet(
      Excel excel, List<LaborEntity> labors, DateFormat fmt) {
    final sheet = excel['Labores'];
    _appendHeader(
        sheet, ['Actividad', 'Fecha', 'Trabajadores', 'Horas', 'Costo']);
    for (final l in labors) {
      sheet.appendRow([
        TextCellValue(l.activityType),
        TextCellValue(fmt.format(l.performedAt)),
        IntCellValue(l.workersCount),
        l.hoursWorked != null
            ? DoubleCellValue(l.hoursWorked!)
            : TextCellValue('—'),
        l.cost != null ? DoubleCellValue(l.cost!) : TextCellValue('—'),
      ]);
    }
  }
}
