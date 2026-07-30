import 'package:dio/dio.dart';
import 'package:futdraw/core/network/dio_client.dart';
import 'package:futdraw/data/remote/auth_remote_datasource.dart';
import 'package:futdraw/data/remote/group_remote_datasource.dart';
import 'package:futdraw/data/remote/player_remote_datasource.dart';
import 'package:futdraw/data/remote/sorteio_ia_remote_datasource.dart';
import 'package:futdraw/data/remote/sorteio_remote_datasource.dart';
import 'package:futdraw/repositories/group_repository.dart';
import 'package:futdraw/repositories/player_repository.dart';
import 'package:futdraw/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._();
  factory ServiceLocator() => _instance;
  ServiceLocator._();

  late AuthService authService;
  late Dio dio;
  late AuthRemoteDataSource authDataSource;
  late GroupRemoteDataSource groupDataSource;
  late PlayerRemoteDataSource playerDataSource;
  late SorteioRemoteDataSource sorteioDataSource;
  late SorteioIARemoteDataSource sorteioIADataSource;
  late GroupRepository groupRepository;
  late PlayerRepository playerRepository;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final sl = ServiceLocator();

    sl.authService = AuthService(prefs);
    sl.dio = DioClient.create(sl.authService);
    sl.authDataSource = AuthRemoteDataSource(sl.dio);
    sl.groupDataSource = GroupRemoteDataSource(sl.dio);
    sl.playerDataSource = PlayerRemoteDataSource(sl.dio);
    sl.sorteioDataSource = SorteioRemoteDataSource(sl.dio);
    sl.sorteioIADataSource = SorteioIARemoteDataSource(sl.dio);
    sl.groupRepository = GroupRepository(sl.groupDataSource);
    sl.playerRepository = PlayerRepository(sl.playerDataSource);
  }
}
