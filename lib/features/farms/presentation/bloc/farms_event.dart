import 'package:equatable/equatable.dart';

abstract class FarmsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFarms extends FarmsEvent {}

class CreateFarm extends FarmsEvent {
  final String name;
  final String? description;
  final double? lat;
  final double? lng;
  final double? areaHa;
  final String? country;
  final String? region;

  CreateFarm({
    required this.name,
    this.description,
    this.lat,
    this.lng,
    this.areaHa,
    this.country,
    this.region,
  });

  @override
  List<Object?> get props =>
      [name, description, lat, lng, areaHa, country, region];
}

class DeleteFarm extends FarmsEvent {
  final String id;
  DeleteFarm(this.id);

  @override
  List<Object?> get props => [id];
}
