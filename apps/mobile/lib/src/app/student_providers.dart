import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection.dart';
import '../features/incidents/domain/repositories/incidents_repository.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/reservations/domain/repositories/reservations_repository.dart';
import '../features/trip/domain/repositories/trip_repository.dart';

/// Expone al árbol los repositorios del módulo estudiante (registrados en
/// `get_it`) para que las pantallas usen `context.read`, igual que `auth`.
class StudentProviders extends StatelessWidget {
  const StudentProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ReservationsRepository>.value(
          value: getIt<ReservationsRepository>(),
        ),
        RepositoryProvider<TripRepository>.value(
          value: getIt<TripRepository>(),
        ),
        RepositoryProvider<IncidentsRepository>.value(
          value: getIt<IncidentsRepository>(),
        ),
        RepositoryProvider<ProfileRepository>.value(
          value: getIt<ProfileRepository>(),
        ),
      ],
      child: child,
    );
  }
}
