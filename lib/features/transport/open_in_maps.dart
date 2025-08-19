import 'package:url_launcher/url_launcher.dart';

Future<void> openInGoogleMaps(double lat, double lng, {String? query}) async {
  final String q = query != null ? Uri.encodeComponent(query) : '$lat,$lng';
  final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}


