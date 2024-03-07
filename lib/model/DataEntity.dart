class DataEntity {
  final int id;
  final String data;
  final String createId;
  final String createTime;
  final String updateId;
  final String updateTime;


  DataEntity({
    required this.id,
    required this.data,
    required this.createTime,
    required this.createId,
    required this.updateTime,
    required this.updateId,
  });

  factory DataEntity.fromJson(Map<String, dynamic> json) {
    return DataEntity(
      id: json['id'] as int,
      data: json['data'] as String,
      createTime: json['createTime'] as String,
      createId: json['createId'] as String,
      updateTime: json['updateTime'] as String,
      updateId: json['updateId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'createTime': createTime,
      'createId': createId,
      'updateTime': updateTime,
      'updateId': updateId,
    };
  }
}
