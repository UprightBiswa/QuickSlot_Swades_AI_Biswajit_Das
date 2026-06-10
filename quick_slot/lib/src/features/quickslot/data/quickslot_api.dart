import 'package:dio/dio.dart';
import 'package:quick_slot/src/config/app_config.dart';
import 'package:quick_slot/src/features/quickslot/data/quickslot_models.dart';

class SlotTakenException implements Exception {
  const SlotTakenException(this.message);

  final String message;

  @override
  String toString() => message;
}

class QuickSlotApi {
  QuickSlotApi(this._dio);

  final Dio _dio;

  Future<List<Venue>> getVenues() async {
    final response = await _dio.get<List<dynamic>>('/venues');
    return response.data!
        .map((item) => Venue.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Slot>> getSlots({required int venueId, required DateTime date}) async {
    final response = await _dio.get<List<dynamic>>(
      '/venues/$venueId/slots',
      queryParameters: {'date': _dateOnly(date)},
    );
    return response.data!
        .map((item) => Slot.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Booking> createBooking({
    required Slot slot,
    required QuickUser user,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/bookings',
        data: {'slot_id': slot.id, 'user_name': user.name},
        options: Options(headers: {'X-User-Id': user.id}),
      );
      return Booking.fromJson(response.data!);
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        final data = error.response?.data;
        final message = data is Map<String, dynamic>
            ? data['detail']?.toString() ?? 'This slot was just booked.'
            : 'This slot was just booked.';
        throw SlotTakenException(message);
      }
      rethrow;
    }
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    final response = await _dio.get<List<dynamic>>('/users/$userId/bookings');
    return response.data!
        .map((item) => Booking.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> cancelBooking({required int bookingId, required QuickUser user}) async {
    await _dio.delete<void>(
      '/bookings/$bookingId',
      options: Options(headers: {'X-User-Id': user.id}),
    );
  }

  String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

final quickSlotApi = QuickSlotApi(AppConfig.dio);
