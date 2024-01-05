class DataEntity {
  final int id;
  final double currentWeight;
  final double proportion;
  final String createTime;
  final String createId;
  final String updateTime;
  final String updateId;

  DataEntity({
    required this.id,
    required this.currentWeight,
    required this.proportion,
    required this.createTime,
    required this.createId,
    required this.updateTime,
    required this.updateId,
  });

  factory DataEntity.fromJson(Map<String, dynamic> json) {
    return DataEntity(
      id: json['id'] as int,
      currentWeight: json['currentWeight'] as double,
      proportion: json['proportion'] as double,
      createTime: json['createTime'] as String,
      createId: json['createId'] as String,
      updateTime: json['updateTime'] as String,
      updateId: json['updateId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currentWeight': currentWeight,
      'proportion': proportion,
      'createTime': createTime,
      'createId': createId,
      'updateTime': updateTime,
      'updateId': updateId,
    };
  }
}
