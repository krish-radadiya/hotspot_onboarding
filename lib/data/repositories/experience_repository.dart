import 'package:dio/dio.dart';
import 'package:hotspot_onboarding/data/models/experience_model.dart';

class ExperienceRepository {
  final Dio _dio;

  ExperienceRepository({Dio? dio})
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: 'https://staging.chamberofsecrets.8club.co',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

  Future<List<Experience>> fetchExperiences() async {
    try {
      final resp = await _dio.get('/v1/experiences', queryParameters: {'active': true});
      // check structure: resp.data['data']['experiences']
      final data = resp.data;
      if (data == null || data['data'] == null || data['data']['experiences'] == null) {
        throw Exception('Invalid response structure');
      }
      final list = (data['data']['experiences'] as List<dynamic>);
      return list.map((e) => Experience.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      // rethrow with readable message
      final msg = e.response?.data?.toString() ?? e.message;
      throw Exception('Failed to load experiences: $msg');
    } catch (e) {
      throw Exception('Failed to load experiences: $e');
    }
  }
}
