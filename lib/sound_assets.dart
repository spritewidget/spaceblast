part of game;

class SoundAssets {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final Map<String, AudioPlayer> _effectPlayers = {};
  SoundAssets(this.bundle);

  final AssetBundle bundle;

  Future<void> loadEffect(String name) async {
    final player = AudioPlayer();
    player.setAsset(_effectPathForName(name));
    await player.load();
    _effectPlayers[name] = player;
  }

  Future<void> loadMusic(String name) async {
    final player = AudioPlayer();
    player.setAsset(_musicPathForName(name));
    await player.load();
  }

  void playEffect(String name) {
    _effectPlayers[name]?.setAsset(_effectPathForName(name));
    _effectPlayers[name]?.play();
  }

  void playMusic(String name) {
    _musicPlayer.setAsset(_musicPathForName(name));
    _musicPlayer.setLoopMode(LoopMode.all);
    _musicPlayer.play();
  }

  String _effectPathForName(String name) => 'assets/$name.wav';

  String _musicPathForName(String name) => 'assets/$name.mp3';
}
