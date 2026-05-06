import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/crop_images/data/datasources/crop_images_remote_datasource.dart';
import '../../features/crops/data/datasources/crops_remote_datasource.dart';
import '../../features/crops/data/repositories/crops_repository_impl.dart';
import '../../features/crops/domain/repositories/crops_repository.dart';
import '../../features/crops/presentation/bloc/crop_detail_cubit.dart';
import '../../features/crops/presentation/bloc/crops_bloc.dart';
import '../../features/farms/data/datasources/farms_remote_datasource.dart';
import '../../features/farms/data/repositories/farms_repository_impl.dart';
import '../../features/farms/domain/repositories/farms_repository.dart';
import '../../features/farms/presentation/bloc/farms_bloc.dart';
import '../../features/fertilization/data/datasources/fertilization_remote_datasource.dart';
import '../../features/irrigation/data/datasources/irrigation_remote_datasource.dart';
import '../../features/labor/data/datasources/labor_remote_datasource.dart';
import '../../features/plots/data/datasources/plots_remote_datasource.dart';
import '../../features/plots/data/repositories/plots_repository_impl.dart';
import '../../features/plots/domain/repositories/plots_repository.dart';
import '../../features/plots/presentation/bloc/plots_bloc.dart';
import '../api/dio_client.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  const storage = FlutterSecureStorage();
  sl.registerSingleton<FlutterSecureStorage>(storage);

  sl.registerSingleton<Dio>(DioClient.createDio(storage));

  // Auth
  sl.registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasource(sl()));
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl()));
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));

  // Farms
  sl.registerLazySingleton<FarmsRemoteDatasource>(
      () => FarmsRemoteDatasource(sl()));
  sl.registerLazySingleton<FarmsRepository>(() => FarmsRepositoryImpl(sl()));
  sl.registerFactory<FarmsBloc>(() => FarmsBloc(sl()));

  // Plots
  sl.registerLazySingleton<PlotsRemoteDatasource>(
      () => PlotsRemoteDatasource(sl()));
  sl.registerLazySingleton<PlotsRepository>(() => PlotsRepositoryImpl(sl()));
  sl.registerFactory<PlotsBloc>(() => PlotsBloc(sl()));

  // Crops
  sl.registerLazySingleton<CropsRemoteDatasource>(
      () => CropsRemoteDatasource(sl()));
  sl.registerLazySingleton<CropsRepository>(() => CropsRepositoryImpl(sl()));
  sl.registerFactory<CropsBloc>(() => CropsBloc(sl()));

  sl.registerLazySingleton(() => IrrigationRemoteDatasource(sl()));
  sl.registerLazySingleton(() => FertilizationRemoteDatasource(sl()));
  sl.registerLazySingleton(() => LaborRemoteDatasource(sl()));
  sl.registerLazySingleton(() => CropImagesRemoteDatasource(sl()));
  sl.registerFactory(() => CropDetailCubit(
        irrigationDs: sl(),
        fertilizationDs: sl(),
        laborDs: sl(),
        imagesDs: sl(),
      ));
}
