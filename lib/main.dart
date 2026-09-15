import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/theme/osis_theme.dart';
import 'data/repositories/case_repository.dart';
import 'domain/coop/coop_engine.dart';
import 'domain/engines/game_engine.dart';
import 'presentation/coop/mode_select_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const UltimoAcessoApp());
}

class UltimoAcessoApp extends StatelessWidget {
  const UltimoAcessoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => CaseRepository()),
        Provider(create: (_) => SaveService()),
        ChangeNotifierProvider(create: (_) => GameEngine()),
        ChangeNotifierProxyProvider<GameEngine, CoopEngine>(
          create: (ctx) => CoopEngine(game: ctx.read<GameEngine>()),
          update: (_, game, previous) => previous ?? CoopEngine(game: game),
        ),
      ],
      child: Consumer<GameEngine>(
        builder: (context, engine, _) {
          return MaterialApp(
            title: 'ÚLTIMO ACESSO',
            debugShowCheckedModeBanner: false,
            theme: OsisTheme.dark(fontScale: engine.fontScale),
            home: const ModeSelectScreen(),
          );
        },
      ),
    );
  }
}

/// Autosave mixin helper
Future<void> autosave(BuildContext context) async {
  final engine = context.read<GameEngine>();
  final save = context.read<SaveService>();
  await save.save(engine.progress);
}
