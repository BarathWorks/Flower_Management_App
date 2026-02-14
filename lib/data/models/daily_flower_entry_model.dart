import '../../domain/entities/daily_flower_entry.dart';
import '../../core/utils/type_converters.dart';

class DailyFlowerEntryModel extends DailyFlowerEntry {
  const DailyFlowerEntryModel({
    required super.id,
    required super.entryDate,
    required super.flowerId,
    required super.flowerName,
    required super.totalQuantity,
    required super.totalAmount,
    required super.totalCommission,
    required super.netAmount,
    required super.customerCount,
    required super.createdAt,
  });

  factory DailyFlowerEntryModel.fromDatabase(List<dynamic> row) {
    return DailyFlowerEntryModel(
      id: row[0] as String,
      entryDate: row[1] as DateTime,
      flowerId: row[2] as String,
      flowerName: row[3] as String,
      totalQuantity: TypeConverters.toDouble(row[4]),
      totalAmount: TypeConverters.toDouble(row[5]),
      totalCommission: TypeConverters.toDouble(row[6]),
      netAmount: TypeConverters.toDouble(row[7]),
      customerCount: TypeConverters.toInt(row[8]),
      createdAt: row[9] as DateTime,
    );
  }
}
