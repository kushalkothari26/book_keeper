import 'package:whatsapp_share2/whatsapp_share2.dart';
Future<void> share(String message,String link,String phone,) async {
  await WhatsappShare.share(
    text: message,
    linkUrl: link,
    phone: phone,
  );
}