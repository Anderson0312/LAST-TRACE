import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/osis_theme.dart';
import '../../../data/repositories/case_repository.dart';
import '../../../domain/engines/game_engine.dart';
import '../../../domain/models/models.dart';
import '../../../main.dart';
import '../shared/app_scaffold.dart';

class SettingsApp extends StatelessWidget {
  final VoidCallback onClose;
  const SettingsApp({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final os = engine.c.osState;

    return AppScaffold(
      title: 'Ajustes',
      onClose: onClose,
      body: ListView(
        children: [
          _section('Rede'),
          ListTile(
            title: const Text('Wi‑Fi'),
            subtitle: Text(os['wifi'] == true ? 'Nexa_5G' : 'Off'),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            title: const Text('Bluetooth'),
            subtitle: Text(os['bluetooth'] == true ? 'Ativo' : 'Off'),
          ),
          _section('Privacidade'),
          ListTile(
            title: const Text('Localização'),
            subtitle: Text('Última atualização: ${os['lastLocationUpdate']}'),
            onTap: () {
              engine.discoverClue('CLUE_LOC_OFF');
              engine.discoverClue('CLUE_PARKING');
              autosave(context);
            },
          ),
          ListTile(
            title: const Text('Dispositivos conectados'),
            subtitle: Text(
              engine.progress.remoteAccessDetected
                  ? '1 dispositivo desconhecido'
                  : 'Nenhum dispositivo extra',
              style: TextStyle(
                color: engine.progress.remoteAccessDetected
                    ? OsisTheme.danger
                    : Colors.white54,
              ),
            ),
            onTap: () {
              if (engine.progress.remoteAccessDetected) {
                engine.discoverClue('CLUE_REMOTE_ACCESS');
              }
            },
          ),
          _section('Bateria'),
          ListTile(
            title: Text('${engine.progress.batteryPercent}%'),
            subtitle: Text(
                'Última carga: ${os['lastChargeAt']}\n${engine.c.settingsHints['batteryDrop'] ?? ''}'),
            isThreeLine: true,
            onTap: () {
              engine.discoverClue('CLUE_FILE_DAT');
              autosave(context);
            },
          ),
          _section('Sistema · Jogo'),
          ListTile(
            title: const Text('Salvar progresso'),
            onTap: () async {
              await autosave(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progresso salvo')),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Reiniciar caso'),
            onTap: () async {
              await context.read<SaveService>().clear(engine.c.id);
              engine.debugReset();
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '${os['deviceName']} · ${os['osName']}',
              style: const TextStyle(color: Colors.white30, fontSize: 12),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
        child: Text(t.toUpperCase(),
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8)),
      );
}
