import 'package:flutter_test/flutter_test.dart';
import 'package:nojin/features/notes/domain/rich_block.dart';
import 'package:nojin/features/notes/domain/rich_block_codec.dart';

void main() {
  test('encodes and decodes structured rich documents', () {
    const document = RichDocument([
      RichBlock(id: '1', type: RichBlockType.heading, text: 'عنوان'),
      RichBlock(id: '2', type: RichBlockType.checklist, text: 'کار', checked: true),
      RichBlock(id: '3', type: RichBlockType.code, text: 'final x = 1;'),
    ]);

    final encoded = document.encode();
    expect(RichBlockCodec.isRich(encoded), isTrue);

    final decoded = RichBlockCodec.fromContent(encoded);
    expect(decoded.blocks.length, 3);
    expect(decoded.blocks[1].checked, isTrue);
    expect(decoded.blocks[2].text, 'final x = 1;');
    expect(RichBlockCodec.preview(encoded), 'عنوان\nکار\nfinal x = 1;');
  });

  test('keeps legacy plain text readable', () {
    final document = RichBlockCodec.fromContent('متن قدیمی');
    expect(document.blocks.single.type, RichBlockType.text);
    expect(RichBlockCodec.preview('متن قدیمی'), 'متن قدیمی');
  });
}
