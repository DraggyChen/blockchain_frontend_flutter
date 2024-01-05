class BlockEntity {
  final int no;
  final int nonce;
  final String data;
  final String time;
  final String previousHash;
  final String hash;
  final String hashKey;

  BlockEntity({
    required this.no,
    required this.nonce,
    required this.data,
    required this.time,
    required this.previousHash,
    required this.hash,
    required this.hashKey,
  });

  factory BlockEntity.fromJson(Map<String, dynamic> json) {
    return BlockEntity(
      no: json['no'] as int,
      nonce: json['nonce'] as int,
      data: json['data'] as String,
      time: json['time'] as String,
      previousHash: json['previousHash'] as String,
      hash: json['hash'] as String,
      hashKey: json['hashKey'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'nonce': nonce,
      'data': data,
      'time': time,
      'previousHash': previousHash,
      'hash': hash,
      'hashKey': hashKey,
    };
  }
}
