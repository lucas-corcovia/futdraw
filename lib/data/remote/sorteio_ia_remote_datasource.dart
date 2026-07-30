import 'package:dio/dio.dart';
import 'package:futdraw/core/constants/api_constants.dart';
import 'package:futdraw/core/errors/app_exception.dart';
import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/models/requests/salvar_sorteio_request.dart';
import 'package:futdraw/data/models/requests/sortear_ia_request.dart';
import 'package:futdraw/data/models/responses/time_response.dart';
import 'package:futdraw/helpers/team_generator.dart';

class SorteioIARemoteDataSource {
  final Dio _dio;

  SorteioIARemoteDataSource(this._dio);

  Future<AppResult<List<Team>>> sortearIA(
    String grupoId,
    SortearIARequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.grupoSortearIA(grupoId),
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

  Future<AppResult<void>> salvarSorteio(
    String grupoId,
    SalvarSorteioRequest request,
  ) async {
    try {
      await _dio.post(
        ApiConstants.grupoSorteios(grupoId),
        data: request.toJson(),
      );
      return AppResult.success(null);
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }
}
