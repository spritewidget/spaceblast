part of game;

class Explosion extends Node {
  Explosion() {
    zPosition = 10.0;
  }
}

class ExplosionBig extends Explosion {
  ExplosionBig(SpriteSheet sheet) {
    // Add particles
    ParticleSystem particlesDebris = new ParticleSystem(
      sheet["explosion_particle.png"],
      rotateToMovement: true,
      startRotation:90.0,
      startRotationVar: 0.0,
      endRotation: 90.0,
      startSize: 0.3,
      startSizeVar: 0.1,
      endSize: 0.3,
      endSizeVar: 0.1,
      numParticlesToEmit: 25,
      emissionRate:1000.0,
      greenVar: 127,
      redVar: 127,
      life: 0.75,
      lifeVar: 0.5
    );
    particlesDebris.zPosition = 1010.0;
    addChild(particlesDebris);

    ParticleSystem particlesFire = new ParticleSystem(
      sheet["fire_particle.png"],
      colorSequence: new ColorSequence(<Color>[new Color(0xffffff33), new Color(0xffff3333), new Color(0x00ff3333)], <double>[0.0, 0.5, 1.0]),
      numParticlesToEmit: 25,
      emissionRate: 1000.0,
      startSize: 0.5,
      startSizeVar: 0.1,
      endSize: 0.5,
      endSizeVar: 0.1,
      posVar: new Offset(10.0, 10.0),
      speed: 10.0,
      speedVar: 5.0,
      life: 0.75,
      lifeVar: 0.5
    );
    particlesFire.zPosition = 1011.0;
    addChild(particlesFire);

    // Add ring
    Sprite spriteRing = new Sprite(sheet["explosion_ring.png"]);
    spriteRing.transferMode = ui.BlendMode.plus;
    addChild(spriteRing);

    Motion scale = new  MotionTween<double>((a) { spriteRing.scale = a; }, 0.2, 1.0, 0.75);
    Motion scaleAndRemove = new MotionSequence(<Motion>[scale, new MotionRemoveNode(spriteRing)]);
    Motion fade = new MotionTween<double>((a) { spriteRing.opacity = a; }, 1.0, 0.0, 0.75);
    motions.run(scaleAndRemove);
    motions.run(fade);

    // Add streaks
    for (int i = 0; i < 5; i++) {
      Sprite spriteFlare = new Sprite(sheet["explosion_flare.png"]);
      spriteFlare.pivot = new Offset(0.3, 1.0);
      spriteFlare.scaleX = 0.3;
      spriteFlare.transferMode = ui.BlendMode.plus;
      spriteFlare.rotation = randomDouble() * 360.0;
      addChild(spriteFlare);

      double multiplier = randomDouble() * 0.3 + 1.0;

      Motion scale = new MotionTween<double>((a) { spriteFlare.scaleY = a; }, 0.3 * multiplier, 0.8, 0.75 * multiplier);
      Motion scaleAndRemove = new MotionSequence(<Motion>[scale, new MotionRemoveNode(spriteFlare)]);
      Motion fadeIn = new MotionTween<double>((a) { spriteFlare.opacity = a; }, 0.0, 1.0, 0.25 * multiplier);
      Motion fadeOut = new MotionTween<double>((a) { spriteFlare.opacity = a; }, 1.0, 0.0, 0.5 * multiplier);
      Motion fadeInOut = new MotionSequence(<Motion>[fadeIn, fadeOut]);
      motions.run(scaleAndRemove);
      motions.run(fadeInOut);
    }
  }
}

class ExplosionMini extends Explosion {
  ExplosionMini(SpriteSheet sheet) {
    for (int i = 0; i < 2; i++) {
      Sprite star = new Sprite(sheet["star_0.png"]);
      star.scale = 0.5;
      star.colorOverlay = new Color(0xff95f4fb);
      star.transferMode = ui.BlendMode.plus;
      addChild(star);

      double rotationStart = randomDouble() * 90.0;
      double rotationEnd = 180.0 + randomDouble() * 90.0;
      if (i == 0) {
        rotationStart = -rotationStart;
        rotationEnd = -rotationEnd;
      }

      MotionTween rotate = new MotionTween<double>((a) { star.rotation = a; }, rotationStart, rotationEnd, 0.2);
      motions.run(rotate);

      MotionTween fade = new MotionTween<double>((a) { star.opacity = a; }, 1.0, 0.0, 0.2);
      motions.run(fade);
    }

    MotionSequence seq = new MotionSequence(<Motion>[new MotionDelay(0.2), new MotionRemoveNode(this)]);
    motions.run(seq);
  }
}
