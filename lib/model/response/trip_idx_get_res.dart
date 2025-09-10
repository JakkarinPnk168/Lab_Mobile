// To parse this JSON data, do
//
//     final tripIdxGetResponse = tripIdxGetResponseFromJson(jsonString);

import 'dart:convert';

TripIdxGetResponse tripIdxGetResponseFromJson(String str) =>
    TripIdxGetResponse.fromJson(json.decode(str));

String tripIdxGetResponseToJson(TripIdxGetResponse data) =>
    json.encode(data.toJson());

class TripIdxGetResponse {
  int idx;
  String name;
  String country;
  String coverimage;
  String detail;
  int price;
  int duration;
  DestinationZone destinationZone;

  TripIdxGetResponse({
    required this.idx,
    required this.name,
    required this.country,
    required this.coverimage,
    required this.detail,
    required this.price,
    required this.duration,
    required this.destinationZone,
  });

  factory TripIdxGetResponse.fromJson(Map<String, dynamic> json) =>
      TripIdxGetResponse(
        idx: json["idx"],
        name: json["name"],
        country: json["country"],
        coverimage: json["coverimage"],
        detail: json["detail"],
        price: json["price"],
        duration: json["duration"],
        destinationZone: destinationZoneValues.map[json["destination_zone"]]!,
      );

  Map<String, dynamic> toJson() => {
    "idx": idx,
    "name": name,
    "country": country,
    "coverimage": coverimage,
    "detail": detail,
    "price": price,
    "duration": duration,
    "destination_zone": destinationZoneValues.reverse[destinationZone],
  };
}

enum DestinationZone { DESTINATION_ZONE, EMPTY, FLUFFY, PURPLE }

final destinationZoneValues = EnumValues({
  "เอเชียตะวันออกเฉียงใต้": DestinationZone.DESTINATION_ZONE,
  "ยุโรป": DestinationZone.EMPTY,
  "ประเทศไทย": DestinationZone.FLUFFY,
  "เอเชีย": DestinationZone.PURPLE,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
