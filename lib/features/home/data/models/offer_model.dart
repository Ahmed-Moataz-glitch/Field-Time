import 'package:equatable/equatable.dart';

class OfferModel extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String discountText;
  final String imageUrl;
  final String tag;
  final String? fieldId;

  const OfferModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.discountText,
    required this.imageUrl,
    required this.tag,
    this.fieldId,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      discountText: json['discount_text'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      tag: json['tag'] as String? ?? 'خصم لفترة محدودة',
      fieldId: json['field_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'discount_text': discountText,
      'image_url': imageUrl,
      'tag': tag,
      'field_id': fieldId,
    };
  }

  @override
  List<Object?> get props => [id, title, subtitle, discountText, imageUrl, tag, fieldId];
}
