import 'dart:html' as html;

Future<void> setPersistentFlag(String key, String value) async {
  // 400 days
  final DateTime expires = DateTime.now().add(const Duration(days: 400));
  final String cookie = '$key=$value; expires=${expires.toUtc().toIso8601String()}; path=/; SameSite=Lax';
  html.document.cookie = cookie;
}

Future<String?> getPersistentFlag(String key) async {
  final String? all = html.document.cookie;
  if (all == null) return null;
  for (final part in all.split(';')) {
    final kv = part.trim().split('=');
    if (kv.length == 2 && kv[0] == key) return kv[1];
  }
  return null;
}


