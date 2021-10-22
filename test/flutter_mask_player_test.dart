import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_mask_player/flutter_mask_player.dart';

MaskPlayerController initializeController() =>
    MaskPlayerController.network(
      NetworkPlayerData(
        url: "http://upload.wikimedia.org/wikipedia/commons/7/79/Big_Buck_Bunny_small.ogv"
      )
    );

void main() {
  group("Controller tests", () {
    test('Playing state test', () {
      final controller = initializeController();

      expect(controller.isPlaying, false);
      controller.play();
      expect(controller.isPlaying, true);
    });

    test("Auto update state in controller test", () {
      final controller = initializeController();

      expect(controller.isAutoUpdates, false);
      controller.autoUpdatePlayer();
      expect(controller.isAutoUpdates, true);
      controller.autoUpdatePlayer();
      expect(controller.isAutoUpdates, false);
    });

    test("Initialize controller is works", () {
      final controller = initializeController();

      controller.initialize();
      controller.events$.last.then((value) => expect(value, MaskPlayerControllerEvent.initialize));
    });
  });
}
