import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/perfil_estudiante.dart';
import '../../domain/validators/perfil_validator.dart';
import 'perfil_cubit.dart';

Future<void> mostrarEditarContacto(
  BuildContext context,
  PerfilEstudiante perfil,
) {
  final cubit = context.read<PerfilCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _EditarContacto(perfil: perfil),
    ),
  );
}

class _EditarContacto extends StatefulWidget {
  const _EditarContacto({required this.perfil});

  final PerfilEstudiante perfil;

  @override
  State<_EditarContacto> createState() => _EditarContactoState();
}

class _EditarContactoState extends State<_EditarContacto> {
  final _form = GlobalKey<FormState>();
  late final _telefono = TextEditingController(text: widget.perfil.telefono);
  late final _nombre = TextEditingController(
    text: widget.perfil.contactoEmergencia?.nombre,
  );
  late final _parentesco = TextEditingController(
    text: widget.perfil.contactoEmergencia?.parentesco,
  );
  late final _telefonoContacto = TextEditingController(
    text: widget.perfil.contactoEmergencia?.telefono,
  );

  static final _digitos = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ];

  @override
  void dispose() {
    _telefono.dispose();
    _nombre.dispose();
    _parentesco.dispose();
    _telefonoContacto.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<PerfilCubit>().guardarContacto(
      telefono: _telefono.text,
      contacto: ContactoEmergencia(
        nombre: _nombre.text,
        parentesco: _parentesco.text,
        telefono: _telefonoContacto.text,
      ),
    );
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Datos de contacto guardados.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PerfilCubit>().state;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _form,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Editar contacto',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _telefono,
                keyboardType: TextInputType.phone,
                inputFormatters: _digitos,
                validator: PerfilValidator.telefono,
                decoration: const InputDecoration(
                  labelText: 'Tu teléfono',
                  helperText: '10 dígitos',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Contacto de emergencia',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _nombre,
                textCapitalization: TextCapitalization.words,
                validator: PerfilValidator.nombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _parentesco,
                textCapitalization: TextCapitalization.sentences,
                validator: PerfilValidator.parentesco,
                decoration: const InputDecoration(labelText: 'Parentesco'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _telefonoContacto,
                keyboardType: TextInputType.phone,
                inputFormatters: _digitos,
                validator: PerfilValidator.telefono,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              if (state.error != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppAlert(
                  tone: AppAlertTone.danger,
                  title: 'No pudimos guardar',
                  message: state.error,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: state.guardando ? 'Guardando…' : 'Guardar cambios',
                loading: state.guardando,
                expand: true,
                onPressed: _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
