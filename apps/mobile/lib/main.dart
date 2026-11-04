import 'package:flutter/widgets.dart';

import 'src/app/app.dart';
import 'src/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const TransporteApp());
}
