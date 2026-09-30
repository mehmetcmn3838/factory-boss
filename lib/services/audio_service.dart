/// Asset-free audio facade. Real audio files can be connected later without
/// changing game logic. All methods are intentionally safe no-ops in the MVP.
class AudioService {
  bool musicEnabled = true;
  bool soundEnabled = true;

  Future<void> playCoin() async {}
  Future<void> playUpgrade() async {}
  Future<void> playFailure() async {}
  Future<void> playButton() async {}
  Future<void> dispose() async {}
}
