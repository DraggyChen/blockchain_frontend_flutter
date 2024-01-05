

import 'package:blockchain_frontend_flutter/model/BlockEntity.dart';

class BlockDto {
  final List<BlockEntity> blockEntities;
  final BlockEntity? blockEntity;
  final String? errorCode;
  final String? errorMessage;
  final String? devMessage;

  BlockDto({
    required this.blockEntities,
    this.blockEntity,
    this.errorCode,
    this.errorMessage,
    this.devMessage,
  });

  factory BlockDto.fromJson(Map<String, dynamic> json) {
    return BlockDto(
      blockEntities: (json['blockEntities'] as List)
          .map((item) => BlockEntity.fromJson(item))
          .toList(),
      blockEntity: json['blockEntity'] != null
          ? BlockEntity.fromJson(json['blockEntity'])
          : null,
      errorCode: json['errorCode'],
      errorMessage: json['errorMessage'],
      devMessage: json['devMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'blockEntities': blockEntities.map((be) => be.toJson()).toList(),
      'blockEntity': blockEntity?.toJson(),
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'devMessage': devMessage,
    };
  }
}
