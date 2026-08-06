import 'package:dio/dio.dart';
import 'package:futdraw/core/constants/api_constants.dart';
import 'package:futdraw/core/errors/app_exception.dart';
import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/models/requests/member_request.dart';
import 'package:futdraw/data/models/responses/member_response.dart';

class MemberRemoteDataSource {
  final Dio _dio;

  MemberRemoteDataSource(this._dio);

  Future<AppResult<List<MemberResponse>>> getAll(String grupoId) async {
    try {
      final response = await _dio.get(ApiConstants.grupoMembros(grupoId));
      final list = (response.data as List<dynamic>)
          .map((j) => MemberResponse.fromJson(j as Map<String, dynamic>))
          .toList();
      return AppResult.success(list);
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<MemberResponse>> invite(
    String grupoId,
    InviteMemberRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.grupoMembros(grupoId),
        data: request.toJson(),
      );
      return AppResult.success(
        MemberResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<MemberResponse>> changePapel(
    String membroId,
    ChangePapelRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.grupoMembroPapel(membroId),
        data: request.toJson(),
      );
      return AppResult.success(
        MemberResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<void>> remove(String membroId) async {
    try {
      await _dio.delete(ApiConstants.membroById(membroId));
      return AppResult.success(null);
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<void>> claimPlayer(
    String grupoId,
    String jogadorId,
  ) async {
    try {
      await _dio.post(ApiConstants.reivindicarJogador(grupoId, jogadorId));
      return AppResult.success(null);
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }
}
