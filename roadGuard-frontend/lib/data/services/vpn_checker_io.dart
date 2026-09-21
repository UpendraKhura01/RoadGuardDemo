import 'dart:io';

Future<bool> checkVpnInterfaces() async {
  try {
    final interfaces = await NetworkInterface.list(includeLoopback: false, type: InternetAddressType.any);
    for (var interface in interfaces) {
      final name = interface.name.toLowerCase();
      if (name.contains('tun') || name.contains('tap') || name.contains('vpn') || name.contains('ppp')) {
        return true;
      }
    }
    return false;
  } catch (e) {
    return false;
  }
}