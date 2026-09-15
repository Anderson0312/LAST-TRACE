import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/assets/game_images.dart';
import '../../../domain/engines/game_engine.dart';
import '../../../domain/models/models.dart';
import '../../../main.dart';
import '../shared/app_scaffold.dart';

class PulseApp extends StatefulWidget {
  final VoidCallback onClose;
  const PulseApp({super.key, required this.onClose});

  @override
  State<PulseApp> createState() => _PulseAppState();
}

class _PulseAppState extends State<PulseApp> {
  Conversation? _open;

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    if (_open != null) {
      return _ChatView(
        conversation: _open!,
        onBack: () => setState(() => _open = null),
      );
    }

    final convs = [...engine.c.conversations]
      ..sort((a, b) {
        final at = a.messages.isEmpty ? DateTime(2000) : a.messages.last.timestamp;
        final bt = b.messages.isEmpty ? DateTime(2000) : b.messages.last.timestamp;
        return bt.compareTo(at);
      });
    final timeFmt = DateFormat('HH:mm');

    return AppScaffold(
      title: 'WhatsApp',
      accent: const Color(0xFF25D366),
      onClose: widget.onClose,
      body: ListView.separated(
        itemCount: convs.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
        itemBuilder: (_, i) {
          final c = convs[i];
          final last = c.messages.isEmpty ? null : c.messages.last;
          final unread = engine.isConversationUnread(c);
          final preview = last == null
              ? ''
              : last.isDeleted
                  ? (last.deletedPreview ?? 'Mensagem apagada')
                  : last.body;

          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: GameAvatar(
              characterId: c.contactId,
              fallbackLetter: c.displayName,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    c.displayName,
                    style: TextStyle(
                      fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
                if (last != null)
                  Text(
                    timeFmt.format(last.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: unread
                          ? const Color(0xFF25D366)
                          : Colors.white38,
                      fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unread ? Colors.white : Colors.white54,
                      fontWeight: unread ? FontWeight.w500 : FontWeight.w400,
                      fontStyle:
                          last?.isDeleted == true ? FontStyle.italic : null,
                    ),
                  ),
                ),
                if (c.archived) ...[
                  const SizedBox(width: 6),
                  const Text('arquivada',
                      style: TextStyle(fontSize: 10, color: Colors.white38)),
                ],
                if (unread) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF25D366),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            onTap: () {
              engine.markConversationOpened(c.id);
              autosave(context);
              setState(() => _open = c);
            },
          );
        },
      ),
    );
  }
}

class _ChatView extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onBack;
  const _ChatView({required this.conversation, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final fmt = DateFormat('HH:mm');

    return AppScaffold(
      title: conversation.displayName,
      onClose: onBack,
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        itemCount: conversation.messages.length,
        itemBuilder: (_, i) {
          final m = conversation.messages[i];
          final mine = m.senderId == 'self';
          final readable = engine.isMessageReadable(m);

          if (m.isDeleted && !readable) {
            return _bubble(
              mine: mine,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.deletedPreview ?? 'Mensagem apagada',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Conteúdo oculto / apagado',
                      style: TextStyle(fontSize: 11, color: Colors.white38)),
                ],
              ),
              time: fmt.format(m.timestamp),
              onTap: () {
                engine.markMessageOpened(m.id, m.revealsClueIds);
                autosave(context);
              },
            );
          }

          if (!readable) {
            return _bubble(
              mine: mine,
              child: const Text(
                  '🔒 Mensagem bloqueada — precisa de mais contexto',
                  style: TextStyle(color: Colors.white54, fontSize: 13)),
              time: fmt.format(m.timestamp),
            );
          }

          return _bubble(
            mine: mine,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (m.kind == MessageKind.image)
                  const Text('📷 Imagem',
                      style: TextStyle(color: Colors.white70)),
                if (m.kind == MessageKind.voice)
                  const Text('🎤 Mensagem de voz',
                      style: TextStyle(color: Colors.white70)),
                Text(m.body.isEmpty && m.isDeleted
                    ? (m.deletedPreview ?? '…')
                    : m.body),
                if (m.isEdited)
                  const Text('editada',
                      style: TextStyle(fontSize: 10, color: Colors.white38)),
              ],
            ),
            time: fmt.format(m.timestamp),
            onTap: () {
              engine.markMessageOpened(m.id, m.revealsClueIds);
              if (m.isDeleted) {
                engine.discoverClue('CLUE_MSG_DELETED');
              }
              autosave(context);
            },
          );
        },
      ),
    );
  }

  Widget _bubble({
    required bool mine,
    required Widget child,
    required String time,
    VoidCallback? onTap,
  }) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: mine ? const Color(0xFF1F5C2E) : const Color(0xFF1C1F27),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(mine ? 16 : 4),
              bottomRight: Radius.circular(mine ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DefaultTextStyle(
                style: const TextStyle(
                    color: Colors.white, fontSize: 15, height: 1.3),
                child: child,
              ),
              const SizedBox(height: 4),
              Text(time,
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}
