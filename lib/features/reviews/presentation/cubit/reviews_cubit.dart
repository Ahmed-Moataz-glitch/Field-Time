import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_time/features/field_details/data/models/review_model.dart';
import 'package:field_time/features/home/data/repositories/field_repository.dart';

abstract class ReviewsState extends Equatable {
  const ReviewsState();

  @override
  List<Object?> get props => [];
}

class ReviewsInitial extends ReviewsState {}

class ReviewsLoading extends ReviewsState {}

class ReviewsLoaded extends ReviewsState {
  final List<ReviewModel> reviews;
  final double averageRating;
  final bool isSubmitting;
  final String? successMessage;
  final String? errorMessage;

  const ReviewsLoaded({
    required this.reviews,
    required this.averageRating,
    this.isSubmitting = false,
    this.successMessage,
    this.errorMessage,
  });

  ReviewsLoaded copyWith({
    List<ReviewModel>? reviews,
    double? averageRating,
    bool? isSubmitting,
    String? successMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return ReviewsLoaded(
      reviews: reviews ?? this.reviews,
      averageRating: averageRating ?? this.averageRating,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        reviews,
        averageRating,
        isSubmitting,
        successMessage,
        errorMessage,
      ];
}

class ReviewsError extends ReviewsState {
  final String message;

  const ReviewsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReviewsCubit extends Cubit<ReviewsState> {
  final FieldRepository _repository;

  ReviewsCubit(this._repository) : super(ReviewsInitial());

  Future<void> loadReviews(String fieldId) async {
    emit(ReviewsLoading());
    try {
      final reviews = await _repository.getReviewsByFieldId(fieldId);
      final avg = _calculateAverage(reviews);
      emit(ReviewsLoaded(reviews: reviews, averageRating: avg));
    } catch (e) {
      emit(ReviewsError('فشل تحميل التقييمات: ${e.toString()}'));
    }
  }

  Future<bool> addReview({
    required String fieldId,
    required double rating,
    required String comment,
  }) async {
    final currentState = state;
    if (currentState is ReviewsLoaded) {
      emit(currentState.copyWith(isSubmitting: true, clearMessages: true));
    }

    try {
      await _repository.addReview(fieldId: fieldId, rating: rating, comment: comment);
      final updatedList = await _repository.getReviewsByFieldId(fieldId);
      final avg = _calculateAverage(updatedList);

      emit(ReviewsLoaded(
        reviews: updatedList,
        averageRating: avg,
        isSubmitting: false,
        successMessage: 'تم إضافة تقييمك بنجاح!',
      ));
      return true;
    } catch (e) {
      if (state is ReviewsLoaded) {
        emit((state as ReviewsLoaded).copyWith(
          isSubmitting: false,
          errorMessage: 'فشل إضافة التقييم: ${e.toString()}',
        ));
      }
      return false;
    }
  }

  Future<bool> editReview({
    required String reviewId,
    required String fieldId,
    required double rating,
    required String comment,
  }) async {
    final currentState = state;
    if (currentState is ReviewsLoaded) {
      emit(currentState.copyWith(isSubmitting: true, clearMessages: true));
    }

    try {
      await _repository.editReview(
        reviewId: reviewId,
        fieldId: fieldId,
        rating: rating,
        comment: comment,
      );
      final updatedList = await _repository.getReviewsByFieldId(fieldId);
      final avg = _calculateAverage(updatedList);

      emit(ReviewsLoaded(
        reviews: updatedList,
        averageRating: avg,
        isSubmitting: false,
        successMessage: 'تم تعديل تقييمك بنجاح!',
      ));
      return true;
    } catch (e) {
      if (state is ReviewsLoaded) {
        emit((state as ReviewsLoaded).copyWith(
          isSubmitting: false,
          errorMessage: 'فشل تعديل التقييم: ${e.toString()}',
        ));
      }
      return false;
    }
  }

  Future<bool> deleteReview({
    required String reviewId,
    required String fieldId,
  }) async {
    final currentState = state;
    if (currentState is ReviewsLoaded) {
      emit(currentState.copyWith(isSubmitting: true, clearMessages: true));
    }

    try {
      await _repository.deleteReview(reviewId: reviewId, fieldId: fieldId);
      final updatedList = await _repository.getReviewsByFieldId(fieldId);
      final avg = _calculateAverage(updatedList);

      emit(ReviewsLoaded(
        reviews: updatedList,
        averageRating: avg,
        isSubmitting: false,
        successMessage: 'تم حذف التقييم بنجاح!',
      ));
      return true;
    } catch (e) {
      if (state is ReviewsLoaded) {
        emit((state as ReviewsLoaded).copyWith(
          isSubmitting: false,
          errorMessage: 'فشل حذف التقييم: ${e.toString()}',
        ));
      }
      return false;
    }
  }

  double _calculateAverage(List<ReviewModel> reviews) {
    if (reviews.isEmpty) return 5.0;
    final total = reviews.fold<double>(0, (sum, r) => sum + r.rating);
    return (total / reviews.length);
  }
}
