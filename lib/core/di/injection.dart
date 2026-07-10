import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../features/alerts/data/datasources/alerts_remote_datasource.dart';
import '../../features/alerts/data/repositories/alerts_local_repository.dart';
import '../../features/alerts/presentation/bloc/alerts_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/crop_images/data/datasources/crop_images_remote_datasource.dart';
import '../../features/crop_images/data/repositories/crop_images_local_repository.dart';
import '../../features/crops/data/datasources/crops_remote_datasource.dart';
import '../../features/crops/data/repositories/crops_local_repository.dart';
import '../../features/crops/data/repositories/crops_repository_impl.dart';
import '../../features/crops/domain/repositories/crops_repository.dart';
import '../../features/crops/presentation/bloc/crop_comparison_cubit.dart';
import '../../features/crops/presentation/bloc/crop_detail_cubit.dart';
import '../../features/crops/presentation/bloc/crop_prediction_cubit.dart';
import '../../features/crops/presentation/bloc/crops_bloc.dart';
import '../../features/farms/data/datasources/farms_remote_datasource.dart';
import '../../features/farms/data/repositories/farms_local_repository.dart';
import '../../features/farms/data/repositories/farms_repository_impl.dart';
import '../../features/farms/domain/repositories/farms_repository.dart';
import '../../features/farms/presentation/bloc/farms_bloc.dart';
import '../../features/fertilization/data/datasources/fertilization_remote_datasource.dart';
import '../../features/fertilization/data/repositories/fertilization_local_repository.dart';
import '../../features/irrigation/data/datasources/irrigation_remote_datasource.dart';
import '../../features/irrigation/data/repositories/irrigation_local_repository.dart';
import '../../features/labor/data/datasources/labor_remote_datasource.dart';
import '../../features/labor/data/repositories/labor_local_repository.dart';
import '../../features/phenology/data/datasources/phenology_remote_datasource.dart';
import '../../features/phenology/presentation/bloc/phenology_cubit.dart';
import '../../features/plots/data/datasources/plots_remote_datasource.dart';
import '../../features/plots/data/repositories/plots_local_repository.dart';
import '../../features/plots/data/repositories/plots_repository_impl.dart';
import '../../features/plots/domain/repositories/plots_repository.dart';
import '../../features/plots/presentation/bloc/plots_bloc.dart';
import '../../features/sensors/data/datasources/sensors_remote_datasource.dart';
import '../../features/sensors/presentation/bloc/dashboard_cubit.dart';
import '../../features/sensors/presentation/bloc/sensors_cubit.dart';
import '../../features/shifts/data/datasources/shifts_remote_datasource.dart';
import '../../features/shifts/data/repositories/shifts_local_repository.dart';
import '../../features/shifts/presentation/bloc/shifts_cubit.dart';
import '../../features/task/data/datasources/tasks_remote_datasource.dart';
import '../../features/task/data/repositories/tasks_local_repository.dart';
import '../../features/costs/data/datasources/costs_remote_datasource.dart';
import '../../features/users/data/datasources/users_remote_datasource.dart';
import '../../features/users/presentation/bloc/users_cubit.dart';
import '../../features/weather/data/datasources/weather_remote_datasource.dart';
import '../api/dio_client.dart';
import '../services/initial_sync_service.dart';
import '../services/sync_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── Storage ──────────────────────────────────────────────
  // encryptedSharedPreferences: en Android, el backend legacy (default)
  // puede perder los valores guardados tras matar el proceso en background
  // por varias horas (issue conocido de flutter_secure_storage); el backend
  // de EncryptedSharedPreferences es más estable para sesiones de larga vida.
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  sl.registerSingleton<FlutterSecureStorage>(storage);

  // ─── Dio ──────────────────────────────────────────────────
  sl.registerSingleton<Dio>(DioClient.createDio(storage));

  // ─── Auth ─────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasource(sl()));
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc(sl())); // ← LazySingleton

  // ─── Farms ────────────────────────────────────────────────
  sl.registerLazySingleton<FarmsRemoteDatasource>(
      () => FarmsRemoteDatasource(sl()));
  sl.registerLazySingleton<FarmsRepository>(() => FarmsRepositoryImpl(sl()));
  sl.registerLazySingleton<FarmsLocalRepository>(() => FarmsLocalRepository());
  sl.registerFactory<FarmsBloc>(() => FarmsBloc(sl(), sl()));

  // ─── Plots ────────────────────────────────────────────────
  sl.registerLazySingleton<PlotsRemoteDatasource>(
      () => PlotsRemoteDatasource(sl()));
  sl.registerLazySingleton<PlotsRepository>(() => PlotsRepositoryImpl(sl()));
  sl.registerLazySingleton<PlotsLocalRepository>(() => PlotsLocalRepository());
  sl.registerFactory<PlotsBloc>(() => PlotsBloc(sl(), sl()));

  // ─── Crops ────────────────────────────────────────────────
  sl.registerLazySingleton<CropsRemoteDatasource>(
      () => CropsRemoteDatasource(sl()));
  sl.registerLazySingleton<CropsRepository>(() => CropsRepositoryImpl(sl()));
  sl.registerLazySingleton<CropsLocalRepository>(() => CropsLocalRepository());
  sl.registerFactory<CropsBloc>(() => CropsBloc(sl(), sl()));
  sl.registerFactory<CropComparisonCubit>(() => CropComparisonCubit(sl()));
  sl.registerFactory<CropPredictionCubit>(() => CropPredictionCubit(sl()));

  // ─── Datasources remotos ──────────────────────────────────
  sl.registerLazySingleton<IrrigationRemoteDatasource>(
      () => IrrigationRemoteDatasource(sl()));
  sl.registerLazySingleton<FertilizationRemoteDatasource>(
      () => FertilizationRemoteDatasource(sl()));
  sl.registerLazySingleton<LaborRemoteDatasource>(
      () => LaborRemoteDatasource(sl()));
  sl.registerLazySingleton<CropImagesRemoteDatasource>(
      () => CropImagesRemoteDatasource(sl()));

  // ─── Repositorios locales ─────────────────────────────────
  sl.registerLazySingleton<IrrigationLocalRepository>(
      () => IrrigationLocalRepository());
  sl.registerLazySingleton<FertilizationLocalRepository>(
      () => FertilizationLocalRepository());
  sl.registerLazySingleton<LaborLocalRepository>(() => LaborLocalRepository());
  sl.registerLazySingleton<AlertsLocalRepository>(
      () => AlertsLocalRepository());

  // ─── CropDetailCubit ──────────────────────────────────────
  sl.registerFactory<CropDetailCubit>(() => CropDetailCubit(
        irrigationDs: sl(),
        fertilizationDs: sl(),
        laborDs: sl(),
        imagesDs: sl(),
        irrigationLocal: sl(),
        fertilizationLocal: sl(),
        laborLocal: sl(),
        imagesLocal: sl(), // ← nuevo
        tasksLocal: sl(),
      ));

  // ─── Alerts ───────────────────────────────────────────────
  sl.registerLazySingleton<AlertsRemoteDatasource>(
      () => AlertsRemoteDatasource(sl()));
  sl.registerFactory<AlertsCubit>(() => AlertsCubit(sl(), sl()));

  // ─── Sensors ──────────────────────────────────────────────
  sl.registerLazySingleton<SensorsRemoteDatasource>(
      () => SensorsRemoteDatasource(sl()));

  sl.registerFactory<SensorsCubit>(() => SensorsCubit(sl()));

  // ─── Crop Images ─────────────────────────────────────────
  sl.registerLazySingleton<CropImagesLocalRepository>(
      () => CropImagesLocalRepository());

  // ─── Users ───────────────────────────────────────────────
  sl.registerLazySingleton<UsersRemoteDatasource>(
      () => UsersRemoteDatasource(sl()));
  sl.registerFactory<UsersCubit>(() => UsersCubit(sl()));

  // ─── Tasks ───────────────────────────────────────────────
  // Tareas ya no se crean de forma independiente (ver Shifts) — el
  // datasource/repositorio se mantienen solo para el cache offline
  // que usa InitialSyncService.
  sl.registerLazySingleton<TasksRemoteDatasource>(// ← agregar
      () => TasksRemoteDatasource(sl()));
  sl.registerLazySingleton<TasksLocalRepository>(() => TasksLocalRepository());

  // ─── Shifts ──────────────────────────────────────────────
  sl.registerLazySingleton<ShiftsRemoteDatasource>(// ← agregar
      () => ShiftsRemoteDatasource(sl()));
  sl.registerLazySingleton<ShiftsLocalRepository>(
      () => ShiftsLocalRepository());
  sl.registerFactory<ShiftsCubit>(() => ShiftsCubit(sl(), sl(), sl()));

  // ─── Phenology ───────────────────────────────────────────
  sl.registerLazySingleton<PhenologyRemoteDatasource>(
      () => PhenologyRemoteDatasource(sl()));
  sl.registerFactory<PhenologyCubit>(() => PhenologyCubit(sl()));

  // ─── Dashboard ────────────────────────────────────────────
  sl.registerLazySingleton<WeatherRemoteDatasource>(
      () => WeatherRemoteDatasource());
  sl.registerLazySingleton<CostsRemoteDatasource>(
      () => CostsRemoteDatasource(sl()));
  sl.registerFactory<DashboardCubit>(() => DashboardCubit(
        farmsDs: sl(),
        plotsDs: sl(),
        cropsDs: sl(),
        sensorsDs: sl(),
        alertsDs: sl(),
        weatherDs: sl(),
        costsDs: sl(),
      ));

  // ─── Sync ─────────────────────────────────────────────────
  sl.registerLazySingleton<SyncService>(() => SyncService(sl(), sl()));

  // ─── Initial Sync ─────────────────────────────────────────
  sl.registerLazySingleton<InitialSyncService>(() => InitialSyncService(
        farmsDs: sl(),
        plotsDs: sl(),
        cropsDs: sl(),
        alertsDs: sl(),
        tasksDs: sl(), // ← nuevo
        shiftsDs: sl(), // ← nuevo
        farmsLocal: sl(),
        plotsLocal: sl(),
        cropsLocal: sl(),
        alertsLocal: sl(),
        tasksLocal: sl(), // ← nuevo
        shiftsLocal: sl(), // ← nuevo
      ));
}
