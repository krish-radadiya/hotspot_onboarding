// import 'package:dio/dio.dart';
// import 'package:hotspot_onboarding/data/models/experience_model.dart';
//
// class ExperienceRepository {
//   final Dio _dio;
//
//   ExperienceRepository({Dio? dio})
//       : _dio = dio ??
//       Dio(BaseOptions(
//         baseUrl: 'https://staging.chamberofsecrets.8club.co',
//         connectTimeout: const Duration(seconds: 10),
//         receiveTimeout: const Duration(seconds: 10),
//       ));
//
//   Future<List<Experience>> fetchExperiences() async {
//     try {
//       final resp = await _dio.get('/v1/experiences', queryParameters: {'active': true});
//       // check structure: resp.data['data']['experiences']
//       final data = resp.data;
//       if (data == null || data['data'] == null || data['data']['experiences'] == null) {
//         throw Exception('Invalid response structure');
//       }
//       final list = (data['data']['experiences'] as List<dynamic>);
//       return list.map((e) => Experience.fromJson(e as Map<String, dynamic>)).toList();
//     } on DioException catch (e) {
//       // rethrow with readable message
//       final msg = e.response?.data?.toString() ?? e.message;
//       throw Exception('Failed to load experiences: $msg');
//     } catch (e) {
//       throw Exception('Failed to load experiences: $e');
//     }
//   }
// }

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hotspot_onboarding/data/models/experience_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ExperienceRepository {
  final Dio _dio;

  ExperienceRepository({Dio? dio})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: 'https://staging.chamberofsecrets.8club.co',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

  /// Fetch list of experiences from the API
  Future<List<Experience>> fetchExperiences() async {
    // ✅ 1. Check for internet connectivity
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      throw Exception('No Internet Connection. Please check your network.');
    }

    try {
      // ✅ 2. Perform API call
      final response = await _dio.get(
        '/v1/experiences',
        queryParameters: {'active': true},
      );

      // ✅ 3. Validate response
      if (response.statusCode == 200) {
        final data = response.data;

        // Optional debug log
        print('✅ Experience API Response: $data');

        if (data != null &&
            data['data'] != null &&
            data['data']['experiences'] != null) {
          final list = (data['data']['experiences'] as List);
          final experiences =
          list.map((e) => Experience.fromJson(e)).toList();

          // ✅ 4. Log parsed count
          print('🎯 Parsed ${experiences.length} experiences successfully.');
          return experiences;
        } else {
          throw Exception('Invalid response format from server.');
        }
      } else {
        // Handle non-200 responses
        throw Exception(
          'Server responded with status code ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      // ✅ 5. Handle Dio-specific errors
      String message = 'Unknown network error';

      if (e.type == DioExceptionType.connectionTimeout) {
        message = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        message = 'Server took too long to respond.';
      } else if (e.type == DioExceptionType.badResponse) {
        final status = e.response?.statusCode ?? 'Unknown';
        final errMsg = e.response?.data ?? 'No error details';
        message = 'Bad response (Status $status): $errMsg';
      } else if (e.type == DioExceptionType.unknown &&
          e.error is SocketException) {
        message = 'No Internet connection.';
      } else if (e.message != null) {
        message = e.message!;
      }

      print('❌ Dio Error: $message');
      throw Exception(message);
    } catch (e, stack) {
      // ✅ 6. Catch-all for other exceptions
      print('💥 Unexpected Error: $e\n$stack');
      throw Exception('Failed to load experiences: $e');
    }
  }
}
