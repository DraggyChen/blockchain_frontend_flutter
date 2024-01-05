
import 'package:blockchain_frontend_flutter/model/DataEntity.dart';

class DataDto {
  final List<DataEntity> dataEntities;
  DataEntity? dataEntity;
  final String? errorCode;
  final String? errorMessage;
  String? devMessage;

  DataDto({
    required this.dataEntities,
    this.dataEntity,
    this.errorCode,
    this.errorMessage,
    this.devMessage,
  });

  factory DataDto.fromJson(Map<String, dynamic> json) {
    return DataDto(
      dataEntities: (json['dataEntities'] as List)
          .map((item) => DataEntity.fromJson(item))
          .toList(),
      dataEntity: json['dataEntity'] != null
          ? DataEntity.fromJson(json['dataEntity'])
          : null,
      errorCode: json['errorCode'],
      errorMessage: json['errorMessage'],
      devMessage: json['devMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dataEntities': dataEntities.map((be) => be.toJson()).toList(),
      'dataEntity': dataEntity?.toJson(),
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'devMessage': devMessage,
    };
  }
}
