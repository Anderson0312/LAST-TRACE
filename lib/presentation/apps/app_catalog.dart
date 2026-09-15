import 'ios_icons.dart';

class PhoneApp {
  final String id;
  final String name;
  final IosIconStyle iconStyle;

  const PhoneApp({
    required this.id,
    required this.name,
    required this.iconStyle,
  });
}

class AppCatalog {
  /// Grade principal — nomes familiares ao iPhone / apps populares.
  static const homeApps = [
    PhoneApp(id: 'gallery', name: 'Fotos', iconStyle: IosIconStyle.photos),
    PhoneApp(id: 'calendar', name: 'Calendário', iconStyle: IosIconStyle.calendar),
    PhoneApp(id: 'atlas', name: 'Mapas', iconStyle: IosIconStyle.maps),
    PhoneApp(id: 'bank', name: 'Carteira', iconStyle: IosIconStyle.bank),
    PhoneApp(id: 'notes', name: 'Notas', iconStyle: IosIconStyle.notes),
    PhoneApp(id: 'files', name: 'Arquivos', iconStyle: IosIconStyle.files),
    PhoneApp(id: 'pulse', name: 'WhatsApp', iconStyle: IosIconStyle.messages),
    PhoneApp(id: 'vibe', name: 'Instagram', iconStyle: IosIconStyle.instagram),
    PhoneApp(id: 'mailbox', name: 'Mail', iconStyle: IosIconStyle.mail),
    PhoneApp(id: 'contacts', name: 'Contatos', iconStyle: IosIconStyle.contacts),
    PhoneApp(id: 'recorder', name: 'Ditafone', iconStyle: IosIconStyle.voiceMemo),
    PhoneApp(id: 'bank', name: 'Nubank', iconStyle: IosIconStyle.bank),
    PhoneApp(id: 'mystery', name: '???', iconStyle: IosIconStyle.mystery),
    PhoneApp(id: 'investigation', name: 'Quadro', iconStyle: IosIconStyle.board),
    PhoneApp(id: 'trash', name: 'Lixeira', iconStyle: IosIconStyle.trash),
    PhoneApp(id: 'settings', name: 'Ajustes', iconStyle: IosIconStyle.settings),
  ];

  static const dockApps = [
    PhoneApp(id: 'calls', name: 'Telefone', iconStyle: IosIconStyle.phone),
    PhoneApp(id: 'browser', name: 'Safari', iconStyle: IosIconStyle.safari),
    PhoneApp(id: 'pulse', name: 'WhatsApp', iconStyle: IosIconStyle.messages),
    PhoneApp(id: 'camera', name: 'Câmera', iconStyle: IosIconStyle.camera),
  ];

  static String displayName(String appId) {
    for (final a in [...homeApps, ...dockApps]) {
      if (a.id == appId) return a.name;
    }
    return appId;
  }
}
