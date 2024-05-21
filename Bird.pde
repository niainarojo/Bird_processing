// Déclarations des variables globales
PImage[] birdIm;
pillar[] p;
boolean end;
boolean paused;
int score;
int pillarGap;
int obstacleCount;
int index;
PImage[] backgrounds;
int currentBackgroundIndex;
int pillarsPassed;
int highScore;
float minOpeningHeight = 50;
float maxOpeningHeight = 500;
int starsCollected;
Star star;
bird b; // Déclaration de la classe bird

void setup() {
  size(871, 695);
  
  b = new bird();
  birdIm = new PImage[4];
  p = new pillar[3];
  end = false;
  paused = false;
  score = 0;
  pillarGap = 300;
  obstacleCount = 0;
  index = 0;
  currentBackgroundIndex = 0;
  pillarsPassed = 0;
  highScore = 0;
  starsCollected = 0;
  
  backgrounds = new PImage[5];
  backgrounds[0] = loadImage("bg/flowers1.png");
  backgrounds[1] = loadImage("bg/autumn1.png");
  backgrounds[2] = loadImage("bg/summer1.png");
  backgrounds[3] = loadImage("bg/snow1.png");
  backgrounds[4] = loadImage("bg/ete1.png");

  for (int i = 0; i < backgrounds.length; i++) {
    backgrounds[i].resize(871, 695);
  }
  
  for (int j = 0; j < 4; j++) {
    birdIm[j] = loadImage("bird/bird" + (j + 1) + ".png");
  }
  
  for (int i = 0; i < 3; i++) {
    p[i] = new pillar(i);
  }
  
  star = new Star();
}

void draw() {
  background(backgrounds[currentBackgroundIndex]);
  
  if (!end && !paused) {
    b.move();
    b.drawBird();
    b.drag();
    star.drawStar();
    star.checkStar();
    for (int i = 0; i < 3; i++) {
      p[i].drawPillar();
      p[i].checkPosition();
    }
    b.checkCollisions();
    
    if (pillarsPassed == 15) {
      currentBackgroundIndex = (currentBackgroundIndex + 1) % backgrounds.length;
      pillarsPassed = 0;
    }
  } else if (paused) {
    fill(255, 255, 0);
    textSize(64);
    textAlign(CENTER, CENTER);
    text("Paused", width / 2, height / 2);
  }
  
  fill(139, 69, 19);
  textSize(32);
  textAlign(LEFT, TOP);
  text("Score: " + score, 20, 20);
  text("Stars: " + starsCollected, 20, 60);
  
  if (end) {
    fill(255, 0, 0);
    textSize(64);
    textAlign(CENTER, CENTER);
    text("Game Over", width / 2, height / 2 - 80);
    textSize(48);
    text("Score: " + score, width / 2, height / 2);
    text("Best Score: " + highScore, width / 2, height / 2 + 60);
  }
}

class bird {
  float xPos, yPos, ySpeed;
  int animationSpeed = 5;
  int frameCount = 0;
  boolean hasProtection; // Nouvelle variable pour la protection
  
  bird() {
    xPos = 250;
    yPos = 400;
    ySpeed = 0;
    hasProtection = false; // Initialisation de la protection
  }

  void drawBird() {
    pushMatrix();
    translate(xPos + birdIm[index].width, yPos);
    scale(-1, 1);
    image(birdIm[index], 0, 0);
    popMatrix();
    frameCount++;
    if (frameCount % animationSpeed == 0) {
      index = (index + 1) % birdIm.length;
    }
  }

  void jump() {
    ySpeed = -5;
    hasProtection = true; // Activer la protection
  }

  void drag() {
    ySpeed += 0.2;
  } 

  void move() {
    yPos += ySpeed;
    for (int i = 0; i < 3; i++) {
      p[i].xPos -= 3;
    }
  }
  
  void moveRight() {
    xPos += 2;
  }

  void checkCollisions() {
    if (yPos > 695) {
      end = true;
      if (score > highScore) {
        highScore = score;
      }
    }
    for (int i = 0; i < 3; i++) {
      if ((xPos < p[i].xPos + 10 && xPos > p[i].xPos - 10) &&
          (yPos < p[i].opening - 100 || yPos > p[i].opening + 100)) {
        if (!hasProtection) { // Sans protection
          if (starsCollected == 0) {
            end = true; // Game Over si aucune étoile n'a été collectée
            if (score > highScore) {
              highScore = score;
            }
          }
        } else {
          hasProtection = false; // Réinitialisation de la protection après utilisation
          starsCollected--; // Consommer une étoile
          if (starsCollected < 0) {
            starsCollected = 0; // Ne peut pas avoir de nombre négatif d'étoiles
          }
        }
      }
    }
  }
}

class pillar {
  float xPos, opening;
  boolean cashed;

  pillar(int i) {
    xPos = width + (i * pillarGap) + 40;
    opening = random(minOpeningHeight, maxOpeningHeight);
    cashed = false;
  }

  void drawPillar() {
    stroke(139, 69, 19);
    strokeWeight(30);
    line(xPos, 0, xPos, opening - 100);
    line(xPos, opening + 100, xPos, 695);
  }

  void checkPosition() {
    if (xPos < 0) {
      xPos += (pillarGap * 3);
      opening = random(minOpeningHeight, maxOpeningHeight);
      cashed = false;
    }
    if (xPos < 250 && !cashed) {
      cashed = true;
      score++;
      pillarsPassed++;
      obstacleCount++;
    }
  }
}

class Star {
  float xPos, yPos;
  PImage starImage;
  boolean collected;

  Star() {
    starImage = loadImage("bg/star.png");
    starImage.resize(42, 38);
    reset();
  }

  void reset() {
    xPos = random(width, width + 1000);
    yPos = random(100, height - 100);
    collected = false;
  }

  void drawStar() {
    if (!collected) {
      image(starImage, xPos, yPos);
      xPos -= 3;
    }

    if (xPos < -starImage.width) {
      reset();
    }
  }

  void checkStar() {
    if (!collected && dist(b.xPos, b.yPos, xPos, yPos) < 20) {
      collected = true;
      starsCollected++;
      b.hasProtection = true; // Mettre à jour la protection de l'oiseau
      reset();
    }
  }
}

void mousePressed() {
  if (!paused) {
    b.jump();
  }
  if (end) {
    reset();
  }
}

void keyPressed() {
  if (keyCode == LEFT) {
    paused = !paused;
  } else if (keyCode == RIGHT && !paused) {
    b.moveRight();
  } else if (!paused) {
    b.jump();
  }
  if (end) {
    reset();
  }
}

void reset() {
  end = false;
  paused = false;
  score = 0;
  b.xPos = 250;
  b.yPos = 400;
  b.ySpeed = 0;
  starsCollected = 0;
  for (int i = 0; i < 3; i++) {
    p[i].xPos = width + (i * pillarGap) + 40;
    p[i].opening = random(minOpeningHeight, maxOpeningHeight);
    p[i].cashed = false;
  }
  star.reset();
}
