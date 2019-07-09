part of game;

class SoundAssets {
  SoundAssets(this.bundle) {
//    _soundEffectPlayer = new SoundEffectPlayer(20);
  }

  AssetBundle bundle;
//  SoundEffectPlayer _soundEffectPlayer;
//  Map<String, SoundEffect> _soundEffects = <String, SoundEffect>{};

  Future load(String name) async {
//    _soundEffects[name] = await _soundEffectPlayer.load(
//      await _bundle.load('assets/$name.wav')
//    );
  }

  void play(String name) {
//    _soundEffectPlayer.play(_soundEffects[name]);
  }
}
