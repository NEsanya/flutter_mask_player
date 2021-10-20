import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_mask_player/flutter_mask_player.dart';

void main() {
  test('Playing state test', () {
    final controller = MaskPlayerController.network("http://upload.wikimedia.org/wikipedia/commons/7/79/Big_Buck_Bunny_small.ogv", null);
    expect(controller.isPlaying, false);
    controller.play();
    expect(controller.isPlaying, true);
  });
}
