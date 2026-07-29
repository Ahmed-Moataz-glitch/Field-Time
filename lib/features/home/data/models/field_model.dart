import 'package:equatable/equatable.dart';

class FieldModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String city;
  final String area;
  final String address;
  final double pricePerHour;
  final double? oldPrice;
  final double rating;
  final int reviewsCount;
  final String distance;
  final String fieldType;
  final String grassType;
  final bool isIndoor;
  final String mainImage;
  final List<String> images;
  final List<String> facilities;
  final bool isFavorite;

  const FieldModel({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.area,
    required this.address,
    required this.pricePerHour,
    this.oldPrice,
    required this.rating,
    required this.reviewsCount,
    required this.distance,
    required this.fieldType,
    required this.grassType,
    required this.isIndoor,
    required this.mainImage,
    required this.images,
    required this.facilities,
    this.isFavorite = false,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      city: json['city'] as String? ?? 'القاهرة',
      area: json['area'] as String? ?? '',
      address: json['address'] as String? ?? '',
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble() ?? 0.0,
      oldPrice: (json['old_price'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      distance: json['distance'] as String? ?? '1.0 كم',
      fieldType: json['field_type'] as String? ?? 'خماسي',
      grassType: json['grass_type'] as String? ?? 'عشب صناعي',
      isIndoor: json['is_indoor'] as bool? ?? false,
      mainImage: json['main_image'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      facilities: (json['facilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'city': city,
      'area': area,
      'address': address,
      'price_per_hour': pricePerHour,
      'old_price': oldPrice,
      'rating': rating,
      'reviews_count': reviewsCount,
      'distance': distance,
      'field_type': fieldType,
      'grass_type': grassType,
      'is_indoor': isIndoor,
      'main_image': mainImage,
      'images': images,
      'facilities': facilities,
      'is_favorite': isFavorite,
    };
  }

  FieldModel copyWith({
    String? id,
    String? name,
    String? description,
    String? city,
    String? area,
    String? address,
    double? pricePerHour,
    double? oldPrice,
    double? rating,
    int? reviewsCount,
    String? distance,
    String? fieldType,
    String? grassType,
    bool? isIndoor,
    String? mainImage,
    List<String>? images,
    List<String>? facilities,
    bool? isFavorite,
  }) {
    return FieldModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      city: city ?? this.city,
      area: area ?? this.area,
      address: address ?? this.address,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      oldPrice: oldPrice ?? this.oldPrice,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      distance: distance ?? this.distance,
      fieldType: fieldType ?? this.fieldType,
      grassType: grassType ?? this.grassType,
      isIndoor: isIndoor ?? this.isIndoor,
      mainImage: mainImage ?? this.mainImage,
      images: images ?? this.images,
      facilities: facilities ?? this.facilities,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        city,
        area,
        address,
        pricePerHour,
        oldPrice,
        rating,
        reviewsCount,
        distance,
        fieldType,
        grassType,
        isIndoor,
        mainImage,
        images,
        facilities,
        isFavorite,
      ];
}
