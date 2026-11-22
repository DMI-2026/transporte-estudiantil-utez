import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection.dart';
import '../features/operator/domain/repositories/operator_repository.dart';

/// Expone al árbol el repositorio del módulo operador (registrado en
/// `get_it`) para que las pantallas usen `context.read`.
class OperatorProviders extends StatelessWidget {
  const OperatorProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<OperatorRepository>.value(
      value: getIt<OperatorRepository>(),
      child: child,
    );
  }
}
