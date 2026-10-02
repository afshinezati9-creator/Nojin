import 'rich_block.dart';

class RichBlockCodec {
  static bool isRich(String value) {
    return value.trimLeft().startsWith('{"version":1,"blocks":');
  }

  static RichDocument fromContent(String content) => RichDocument.decode(content);

  static String toContent(RichDocument document) => document.encode();

  static String preview(String content) => RichDocument.decode(content).plainText.trim();
}
