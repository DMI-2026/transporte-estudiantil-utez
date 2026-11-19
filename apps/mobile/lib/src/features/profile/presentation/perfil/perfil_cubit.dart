import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/ui_state.dart';
import '../../domain/entities/perfil_estudiante.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/validators/perfil_validator.dart';

part 'perfil_state.dart';

class PerfilCubit extends Cubit<PerfilState> {
  PerfilCubit(this._repository) : super(const PerfilState());

  final ProfileRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(perfil: const UiLoading()));
    final result = await _repository.fetchPerfil();
    if (result.failure != null) {
      emit(
        state.copyWith(
          perfil: UiError(message: result.failure!.userMessage, onRetry: load),
        ),
      );
      return;
    }
    emit(state.copyWith(perfil: UiData(result.value!)));
  }

  /// Valida y guarda teléfono y contacto de emergencia. Devuelve `true` si
  /// se guardó; si no, deja el mensaje en [PerfilState.error].
  Future<bool> guardarContacto({
    required String telefono,
    required ContactoEmergencia contacto,
  }) async {
    final invalido =
        PerfilValidator.telefono(telefono) ??
        PerfilValidator.nombre(contacto.nombre) ??
        PerfilValidator.parentesco(contacto.parentesco) ??
        PerfilValidator.telefono(contacto.telefono);
    if (invalido != null) {
      emit(state.copyWith(error: invalido));
      return false;
    }
    emit(state.copyWith(guardando: true, clearError: true));
    final result = await _repository.guardarContacto(
      telefono: telefono.replaceAll(RegExp(r'\D'), ''),
      contactoEmergencia: ContactoEmergencia(
        nombre: contacto.nombre.trim(),
        parentesco: contacto.parentesco.trim(),
        telefono: contacto.telefono.replaceAll(RegExp(r'\D'), ''),
      ),
    );
    if (result.failure != null) {
      emit(
        state.copyWith(guardando: false, error: result.failure!.userMessage),
      );
      return false;
    }
    emit(state.copyWith(guardando: false, perfil: UiData(result.value!)));
    return true;
  }
}
