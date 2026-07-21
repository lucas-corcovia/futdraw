import 'package:dio/dio.dart';
import 'package:futdraw/core/constants/api_constants.dart';
import 'package:futdraw/core/errors/app_exception.dart';
import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/models/requests/sortear_request.dart';
import 'package:futdraw/data/models/responses/time_response.dart';
import 'package:futdraw/helpers/team_generator.dart';

class SorteioRemoteDataSource {
  final Dio _dio;

  SorteioRemoteDataSource(this._dio);

  Future<AppResult<List<Team>>> sortear(
    String grupoId,
    SortearRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.grupoSortear(grupoId),
        data: request.toJson(),
      );
      final teams = (response.data as List<dynamic>)
          .map((t) => TimeResponse.fromJson(t as Map<String, dynamic>).toModel())
          .toList();
      return AppResult.success(teams);
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }
}
