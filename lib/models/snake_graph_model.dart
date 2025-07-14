class SnakeGraphModel {
  final Map<String, DayData> weeklyData;

  SnakeGraphModel({required this.weeklyData});

  factory SnakeGraphModel.fromJson(Map<String, dynamic> json) {
    final weeklyData = <String, DayData>{};
    
    json.forEach((day, data) {
      if (data is Map<String, dynamic>) {
        weeklyData[day] = DayData.fromJson(data);
      }
    });

    return SnakeGraphModel(weeklyData: weeklyData);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    weeklyData.forEach((day, dayData) {
      data[day] = dayData.toJson();
    });
    return data;
  }

  // Get data for a specific day
  DayData? getDayData(String day) {
    return weeklyData[day];
  }

  // Get all days
  List<String> get days => weeklyData.keys.toList();

  // Get total values for a specific status across all days
  int getTotalForStatus(String status) {
    int total = 0;
    weeklyData.values.forEach((dayData) {
      switch (status.toLowerCase()) {
        case 'booked':
          total += dayData.booked;
          break;
        case 'arrival':
          total += dayData.arrival;
          break;
        case 'intransit':
          total += dayData.inTransit;
          break;
        case 'delivered':
          total += dayData.delivered;
          break;
        case 'return':
          total += dayData.returnCount;
          break;
      }
    });
    return total;
  }

  // Get maximum value across all statuses for scaling
  int get maxValue {
    int max = 0;
    weeklyData.values.forEach((dayData) {
      max = [dayData.booked, dayData.arrival, dayData.inTransit, 
             dayData.delivered, dayData.returnCount].reduce((a, b) => a > b ? a : b);
    });
    return max;
  }
}

class DayData {
  final int booked;
  final int arrival;
  final int inTransit;
  final int delivered;
  final int returnCount;

  DayData({
    required this.booked,
    required this.arrival,
    required this.inTransit,
    required this.delivered,
    required this.returnCount,
  });

  factory DayData.fromJson(Map<String, dynamic> json) {
    return DayData(
      booked: int.tryParse(json['Booked']?.toString() ?? '0') ?? 0,
      arrival: int.tryParse(json['Arrival']?.toString() ?? '0') ?? 0,
      inTransit: int.tryParse(json['InTransit']?.toString() ?? '0') ?? 0,
      delivered: int.tryParse(json['Delivered']?.toString() ?? '0') ?? 0,
      returnCount: int.tryParse(json['Return']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Booked': booked.toString(),
      'Arrival': arrival.toString(),
      'InTransit': inTransit.toString(),
      'Delivered': delivered.toString(),
      'Return': returnCount.toString(),
    };
  }

  // Get total for the day
  int get total => booked + arrival + inTransit + delivered + returnCount;

  // Get value for a specific status
  int getValueForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
        return booked;
      case 'arrival':
        return arrival;
      case 'intransit':
        return inTransit;
      case 'delivered':
        return delivered;
      case 'return':
        return returnCount;
      default:
        return 0;
    }
  }
} 