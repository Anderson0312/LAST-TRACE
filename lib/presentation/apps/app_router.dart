import 'package:flutter/material.dart';
import 'pulse/pulse_app.dart';
import 'gallery/gallery_app.dart';
import 'calls/calls_app.dart';
import 'browser/browser_app.dart';
import 'notes/notes_app.dart';
import 'atlas/atlas_app.dart';
import 'files/files_app.dart';
import 'mailbox/mailbox_app.dart';
import 'investigation/investigation_app.dart';
import 'settings/settings_app.dart';
import 'contacts/contacts_app.dart';
import 'shared/simple_apps.dart';

Widget buildApp(String appId, VoidCallback onClose) {
  switch (appId) {
    case 'pulse':
      return PulseApp(onClose: onClose);
    case 'gallery':
      return GalleryApp(onClose: onClose);
    case 'calls':
      return CallsApp(onClose: onClose);
    case 'browser':
      return BrowserApp(onClose: onClose);
    case 'notes':
      return NotesApp(onClose: onClose);
    case 'atlas':
      return AtlasApp(onClose: onClose);
    case 'files':
      return FilesApp(onClose: onClose);
    case 'mailbox':
      return MailboxApp(onClose: onClose);
    case 'investigation':
      return InvestigationApp(onClose: onClose);
    case 'settings':
      return SettingsApp(onClose: onClose);
    case 'contacts':
      return ContactsApp(onClose: onClose);
    case 'calendar':
      return CalendarApp(onClose: onClose);
    case 'trash':
      return TrashApp(onClose: onClose);
    case 'camera':
      return CameraApp(onClose: onClose);
    case 'recorder':
      return RecorderApp(onClose: onClose);
    case 'bank':
      return BankApp(onClose: onClose);
    case 'vibe':
      return VibeApp(onClose: onClose);
    case 'mystery':
      return MysteryApp(onClose: onClose);
    case 'search':
      return SearchApp(onClose: onClose);
    default:
      return _Unknown(onClose: onClose, id: appId);
  }
}

class _Unknown extends StatelessWidget {
  final VoidCallback onClose;
  final String id;
  const _Unknown({required this.onClose, required this.id});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('App: $id', style: const TextStyle(color: Colors.white)),
          TextButton(onPressed: onClose, child: const Text('Fechar')),
        ],
      ),
    );
  }
}
