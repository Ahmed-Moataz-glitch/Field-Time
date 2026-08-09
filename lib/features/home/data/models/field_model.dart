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
  final bool isPopular;
  final bool isRecommended;
  final bool isAvailableToday;
  final String? openingTime;
  final String? closingTime;
  final String? phone;
  final String? couponCode;
  final String? couponTag;

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
    this.isPopular = false,
    this.isRecommended = false,
    this.isAvailableToday = true,
    this.openingTime,
    this.closingTime,
    this.phone,
    this.couponCode,
    this.couponTag,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['field_images'] is List) {
      parsedImages = (json['field_images'] as List)
          .map((img) => img['image_url'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    } else if (json['images'] is List) {
      parsedImages = (json['images'] as List).map((e) => e.toString()).toList();
    }

    final mainImg = parsedImages.isNotEmpty
        ? parsedImages.first
        : (json['main_image'] as String? ?? '');

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
      distance: json['distance'] as String? ?? '1.2 كم',
      fieldType: json['field_type'] as String? ?? 'خماسي',
      grassType: json['grass_type'] as String? ?? 'عشب صناعي',
      isIndoor: json['is_indoor'] as bool? ?? false,
      mainImage: mainImg,
      images: parsedImages,
      facilities: (json['facilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isFavorite: json['is_favorite'] as bool? ?? false,
      isPopular: json['is_popular'] as bool? ?? false,
      isRecommended: json['is_recommended'] as bool? ?? false,
      isAvailableToday: json['is_available_today'] as bool? ?? true,
      openingTime: json['opening_time'] as String?,
      closingTime: json['closing_time'] as String?,
      phone: json['phone'] as String?,
      couponCode: json['coupon_code'] as String?,
      couponTag: json['coupon_tag'] as String?,
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
      'is_popular': isPopular,
      'is_recommended': isRecommended,
      'is_available_today': isAvailableToday,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'phone': phone,
      'coupon_code': couponCode,
      'coupon_tag': couponTag,
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
    bool? isPopular,
    bool? isRecommended,
    bool? isAvailableToday,
    String? openingTime,
    String? closingTime,
    String? phone,
    String? couponCode,
    String? couponTag,
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
      isPopular: isPopular ?? this.isPopular,
      isRecommended: isRecommended ?? this.isRecommended,
      isAvailableToday: isAvailableToday ?? this.isAvailableToday,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      phone: phone ?? this.phone,
      couponCode: couponCode ?? this.couponCode,
      couponTag: couponTag ?? this.couponTag,
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
        isPopular,
        isRecommended,
        isAvailableToday,
        openingTime,
        closingTime,
        phone,
        couponCode,
        couponTag,
      ];
}
