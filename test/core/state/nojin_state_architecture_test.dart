import 'package:flutter_test/flutter_test.dart';

import 'package:nojin/core/state/nojin_use_case.dart';

void main() {
  test('use case contracts keep input and output explicit', () async {
    final useCase = _EchoUseCase();

    expect(await useCase.execute('نوژین'), 'نوژین');
  });
}

class _EchoUseCase implements NojinUseCase<String, String> {
  @override
  Future<String> execute(String input) async => input;
}
