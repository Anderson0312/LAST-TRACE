import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../domain/engines/game_engine.dart';
import '../../../main.dart';
import '../shared/app_scaffold.dart';

class MailboxApp extends StatefulWidget {
  final VoidCallback onClose;
  const MailboxApp({super.key, required this.onClose});

  @override
  State<MailboxApp> createState() => _MailboxAppState();
}

class _MailboxAppState extends State<MailboxApp> {
  String folder = 'inbox';

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final fmt = DateFormat('dd/MM HH:mm');
    final mails = engine.c.emails.where((e) {
      switch (folder) {
        case 'drafts':
          return e.isDraft;
        case 'trash':
          return e.isTrash;
        case 'spam':
          return e.isSpam;
        default:
          return !e.isDraft && !e.isTrash;
      }
    }).toList();

    return AppScaffold(
      title: 'Mail',
      onClose: widget.onClose,
      actions: [
        PopupMenuButton<String>(
          onSelected: (v) => setState(() => folder = v),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'inbox', child: Text('Caixa de entrada')),
            PopupMenuItem(value: 'drafts', child: Text('Rascunhos')),
            PopupMenuItem(value: 'trash', child: Text('Lixeira')),
            PopupMenuItem(value: 'spam', child: Text('Spam')),
          ],
        ),
      ],
      body: ListView.builder(
        itemCount: mails.length,
        itemBuilder: (_, i) {
          final e = mails[i];
          return ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(e.subject,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${e.from}\n${e.body.split('\n').first}',
                maxLines: 2),
            trailing: Text(fmt.format(e.timestamp),
                style: const TextStyle(fontSize: 11, color: Colors.white38)),
            isThreeLine: true,
            onTap: () {
              engine.revealFromContent(e.revealsClueIds);
              autosave(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: const Color(0xFF14161C),
                builder: (_) => DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.7,
                  builder: (_, c) => ListView(
                    controller: c,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(e.subject,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('De: ${e.from}',
                          style: const TextStyle(color: Colors.white54)),
                      Text('Para: ${e.to.join(', ')}',
                          style: const TextStyle(color: Colors.white54)),
                      if (e.bcc.isNotEmpty)
                        Text('Cco: ${e.bcc.join(', ')}',
                            style: const TextStyle(color: Colors.white54)),
                      const SizedBox(height: 16),
                      Text(e.body, style: const TextStyle(height: 1.45)),
                      if (e.attachments.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('Anexos: ${e.attachments.join(', ')}'),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
