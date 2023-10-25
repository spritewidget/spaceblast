part of 'game_demo.dart';

class Explosion extends Node {
  Explosion() {
    zPosition = 10.0;
  }
}

class ExplosionBig extends Explosion {
  ExplosionBig(SpriteSheet sheet) {
    // Add particles
    ParticleSystem particlesDebris = ParticleSystem(
      texture: sheet["explosion_particle.png"]!,
      rotateToMovement: true,
      startRotation: 90.0,
      startRotationVar: 0.0,
      endRotation: 90.0,
      startSize: 0.3,
      startSizeVar: 0.1,
      endSize: 0.3,
      endSizeVar: 0.1,
      numParticlesToEmit: 25,
      emissionRate: 1000.0,
      greenVar: 127,
      redVar: 127,
      life: 0.75,
      lifeVar: 0.5,
    );
    particlesDebris.zPosition = 1010.0;
    addChild(particlesDebris);

    ParticleSystem particlesFire = ParticleSystem(
      texture: sheet["fire_particle.png"]!,
      colorSequence: ColorSequence(
        colors: [
          const Color(0xffffff33),
          const Color(0xffff3333),
          const Color(0x00ff3333)
        ],
        stops: [
          0.0,
          0.5,
          1.0,
        ],
      ),
      numParticlesToEmit: 25,
      emissionRate: 1000.0,
      startSize: 0.5,
      startSizeVar: 0.1,
      endSize: 0.5,
      endSizeVar: 0.1,
      posVar: const Offset(10.0, 10.0),
      speed: 10.0,
      speedVar: 5.0,
      life: 0.75,
      lifeVar: 0.5,
    );
    particlesFire.zPosition = 1011.0;
    addChild(particlesFire);

    // Add ring
    Sprite spriteRing = Sprite(texture: sheet["explosion_ring.png"]!);
    spriteRing.blendMode = ui.BlendMode.plus;
    addChild(spriteRing);

    Motion scale = MotionTween<double>(
      setter: (a) => spriteRing.scale = a,
      start: 0.2,
      end: 1.0,
      duration: 0.75,
    );
    Motion scaleAndRemove = MotionSequence(
      motions: <Motion>[scale, MotionRemoveNode(node: spriteRing)],
    );
    Motion fade = MotionTween<double>(
      setter: (a) => spriteRing.opacity = a,
      start: 1.0,
      end: 0.0,
      duration: 0.75,
    );
    motions.run(scaleAndRemove);
    motions.run(fade);

    // Add streaks
    for (int i = 0; i < 5; i++) {
      Sprite spriteFlare = Sprite(texture: sheet["explosion_flare.png"]!);
      spriteFlare.pivot = const Offset(0.3, 1.0);
      spriteFlare.scaleX = 0.3;
      spriteFlare.blendMode = ui.BlendMode.plus;
      spriteFlare.rotation = randomDouble() * 360.0;
      addChild(spriteFlare);

      double multiplier = randomDouble() * 0.3 + 1.0;

      Motion scale = MotionTween<double>(
        setter: (a) => spriteFlare.scaleY = a,
        start: 0.3 * multiplier,
        end: 0.8,
        duration: 0.75 * multiplier,
      );
      Motion scaleAndRemove = MotionSequence(
        motions: [
          scale,
          MotionRemoveNode(node: spriteFlare),
        ],
      );
      Motion fadeIn = MotionTween<double>(
        setter: (a) => spriteFlare.opacity = a,
        start: 0.0,
        end: 1.0,
        duration: 0.25 * multiplier,
      );
      Motion fadeOut = MotionTween<double>(
        setter: (a) => spriteFlare.opacity = a,
        start: 1.0,
        end: 0.0,
        duration: 0.5 * multiplier,
      );
      Motion fadeInOut = MotionSequence(motions: [fadeIn, fadeOut]);
      motions.run(scaleAndRemove);
      motions.run(fadeInOut);
    }
  }
}

class ExplosionMini extends Explosion {
  ExplosionMini(SpriteSheet sheet) {
    for (int i = 0; i < 2; i++) {
      Sprite star = Sprite(texture: sheet["star_0.png"]!);
      star.scale = 0.5;
      star.colorOverlay = const Color(0xff95f4fb);
      star.blendMode = ui.BlendMode.plus;
      addChild(star);

      double rotationStart = randomDouble() * 90.0;
      double rotationEnd = 180.0 + randomDouble() * 90.0;
      if (i == 0) {
        rotationStart = -rotationStart;
        rotationEnd = -rotationEnd;
      }

      MotionTween rotate = MotionTween<double>(
        setter: (a) => star.rotation = a,
        start: rotationStart,
        end: rotationEnd,
        duration: 0.2,
      );
      motions.run(rotate);

      MotionTween fade = MotionTween<double>(
        setter: (a) => star.opacity = a,
        start: 1.0,
        end: 0.0,
        duration: 0.2,
      );
      motions.run(fade);
    }

    MotionSequence seq = MotionSequence(
      motions: [
        MotionDelay(delay: 0.2),
        MotionRemoveNode(node: this),
      ],
    );
    motions.run(seq);
  }
}
