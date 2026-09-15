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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomPaint(
              painter: _BatteryGraphPainter(),
              child: const SizedBox(height: 80, width: double.infinity),
            ),
          ),
          _section('Armazenamento'),
          ListTile(
            title: const Text('Fotos — 8,2 GB'),
            subtitle: Text(
                'Vídeos — 4,1 GB\nPulse — 620 MB\n${os['mysteriousFile']} — 48 MB'),
            isThreeLine: true,
            onTap: () {
              engine.discoverClue('CLUE_FILE_DAT');
              engine.openApp('files');
            },
          ),
          _section('Tela e acessibilidade'),
          SwitchListTile(
            title: const Text('Reduzir animações'),
            value: engine.reduceMotion,
            onChanged: engine.setReduceMotion,
          ),
          SwitchListTile(
            title: const Text('Vibração'),
            value: engine.hapticsEnabled,
            onChanged: (v) {
              HapticService.enabled = v;
              engine.setHaptics(v);
            },
          ),
          ListTile(
            title: const Text('Tamanho da fonte'),
            subtitle: Slider(
              value: engine.fontScale,
              min: 0.9,
              max: 1.3,
              onChanged: engine.setFontScale,
            ),
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
          if (engine.debugMode) ...[
            _section('Debug'),
            ListTile(
              title: const Text('Desbloquear todas as pistas'),
              onTap: engine.debugUnlockAll,
            ),
            ListTile(
              title: const Text('Simular acesso remoto'),
              onTap: engine.triggerRemoteAccess,
            ),
            ListTile(
              title: const Text('Simular notificação'),
              onTap: () => engine.pushNotification(
                PhoneNotification(
                  id: 'dbg',
                  appId: 'pulse',
                  title: 'Debug',
                  body: 'Notificação de teste',
                ),
              ),
            ),
          ],
          ListTile(
            title: const Text('Desligar'),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => const AlertDialog(
                  backgroundColor: Colors.black,
                  content: Text('Reiniciando VANTA…',
                      style: TextStyle(color: Colors.white)),
                ),
              );
              Future.delayed(const Duration(seconds: 2), () {
                if (context.mounted) Navigator.pop(context);
              });
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

class _BatteryGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = OsisTheme.accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height * 0.2)
      ..lineTo(size.width * 0.25, size.height * 0.25)
      ..lineTo(size.width * 0.5, size.height * 0.35)
      ..lineTo(size.width * 0.7, size.height * 0.55)
      ..lineTo(size.width * 0.85, size.height * 0.85)
      ..lineTo(size.width, size.height * 0.9);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
