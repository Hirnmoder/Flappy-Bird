enum GameState {
  IDLE, PLAYING, RAGDOLL, DEAD
}

private final float PIPE_VERTICAL_GAP = 0.4; //0.25;
private final float PIPES_HORIZONTAL_DISTANCE = 0.6; // Measured in window "heights"
private final float PIPE_WIDTH = 0.1; // Measured in window "heights"
private final float BOTTOM_HITBOX = 0.10;


private final float BIRD_SIZE = 0.0333;
private final float BIRD_DEFAULT_X_POS = 0.125;
private final float BIRD_DEFAULT_X_SPEED = 0.333;
private final float BIRD_X_SPEED_GAIN = 0.0166;
private final float BIRD_X_SPEED_MAX = 0.75;
private final float BIRD_FLYUP = -1.0;
private final float BIRD_FLYDOWN = 3.0;

private float birdXSpeed = this.BIRD_DEFAULT_X_SPEED;
private float birdXPos = this.BIRD_DEFAULT_X_POS;
private float birdYPos = 0.5;
private float birdYSpeed = 0;

private boolean flapRequested = false;
private GameState gameState = GameState.IDLE;
private int score = 0;
private float playTime = 0;
private float idleTime = 0;
private float ragdollTime = 0;
private float backgroundOffset = 0;

private ArrayList<Pipe> pipes = new ArrayList<Pipe>();

private void reset() {
  this.score = 0;
  if (this.gameState != GameState.IDLE)
    this.pipes.clear();
  this.spawnPipes();
  this.birdYPos = 0.5;
  this.birdYSpeed = this.BIRD_FLYUP;
  this.birdXPos = this.BIRD_DEFAULT_X_POS;
  this.birdXSpeed = this.BIRD_DEFAULT_X_SPEED;
  this.gameState = GameState.PLAYING;
  this.playTime = 0;
  this.ragdollTime = 0;
  this.backgroundOffset = 0;
}

void spawnPipes() {
  var nPipes = int(1 / (this.PIPES_HORIZONTAL_DISTANCE - this.PIPE_WIDTH) * width / height) + 1 - this.pipes.size();
  if (nPipes < 0) {
    for (var i = nPipes; i <= 0; i++) {
      // find furthest pipe and remove
      var furthestPipe = this.pipes.get(0);
      for (var pipe : this.pipes) {
        if (pipe.getXPositionRaw() > furthestPipe.getXPositionRaw()) {
          furthestPipe = pipe;
        }
      }
      this.pipes.remove(furthestPipe);
    }
  } else {
    var xOffset = 1.25;
    if (this.pipes.size() > 0) {
      for (var pipe : this.pipes) {
        if (pipe.getXPositionRaw() > xOffset) {
          xOffset = pipe.getXPositionRaw();
        }
      }
      xOffset += this.PIPES_HORIZONTAL_DISTANCE;
    }

    for (var i = 0; i < nPipes; i++) {
      this.pipes.add(new Pipe(xOffset + i * this.PIPES_HORIZONTAL_DISTANCE));
    }
  }

  println("Currently, there are " + this.pipes.size() + " pipes");
}


void drawBackgroundMain() {
  //background(120, 196, 209);
  var bgWidth = int((float)this.imgBackgroundMain.width * height / this.imgBackgroundMain.height);
  var offset = (this.playTime * this.BIRD_DEFAULT_X_SPEED) % 1;
  for (var x = -offset * bgWidth; x <= width; x += bgWidth) {
    image(this.imgBackgroundMain, x, 0, bgWidth, height);
  }
}

void drawBackgroundGround() {
  //fill(128, 64, 32);
  //rect(0, (1 - this.BOTTOM_HITBOX) * height, width, this.BOTTOM_HITBOX * height);
  var bgWidth = int((float)this.imgBackgroundGround.width * this.BOTTOM_HITBOX * height / this.imgBackgroundGround.height);
  if (this.gameState == GameState.PLAYING)
    this.backgroundOffset += this.deltaTime * this.birdXSpeed * height / bgWidth;
  var offset = this.backgroundOffset % 1;
  for (var x = -offset * bgWidth; x <= width; x+= bgWidth) {
    image(this.imgBackgroundGround, x, (1 - this.BOTTOM_HITBOX) * height, bgWidth, this.BOTTOM_HITBOX * height);
  }
}

void drawPipes() {
  for (var pipe : this.pipes) {
    pipe.draw();
  }
}

void drawBird() {
  pushMatrix();
  pushStyle();
  translate(this.birdXPos * width, this.birdYPos * height);
  rotate(0.5 * (HALF_PI - atan2(this.birdXSpeed, this.birdYSpeed)));
  imageMode(CENTER);
  image(this.imgBird, 0, 0, this.BIRD_SIZE * height * 2.0 * 17 / 12, this.BIRD_SIZE * height * 2.0);

  translate(-this.BIRD_SIZE * height * 2.0 * 3 / 17, this.BIRD_SIZE * height * 2.0 * 1 / 12);
  rotate(0.25 * sin(10 * (this.idleTime + this.playTime)));
  image(this.imgWing, -this.BIRD_SIZE * height * 2.0 * 4 / 17, this.BIRD_SIZE * height * 2.0 * 1 / 12, this.BIRD_SIZE * height * 2.0 * 7 / 12, this.BIRD_SIZE * height * 2.0 * 5 / 12);
  popStyle();
  popMatrix();
}

void drawScore() {
  pushStyle();
  stroke(0, 0, 0);
  fill(255, 255, 255);
  strokeWeight(3);
  textAlign(CENTER, CENTER);
  textSize(80);
  text("Score: " + this.score, 0, 0, width, 100);
  popStyle();
}

void drawDebug() {
  {
    var x = (float)mouseX / width;
    var y = (float)mouseY / height;
    if (this.hitSomething(x, y)) {
      fill(255, 0, 0);
    } else {
      fill(0, 255, 0);
    }
    circle(x * width, y * height, this.BIRD_SIZE * height * 2.0);
  }
  {
    noStroke();
    for (int ix = 0; ix < width; ix++) {
      var x = (float)ix / width;
      for (int iy = 0; iy < height; iy++) {
        var y = (float)iy / height;
        if (this.hitSomething(x, y)) {
          fill(255, 0, 0, 32);
        } else {
          fill(0, 255, 0, 32);
        }
        rect(ix, iy, 1, 1);
      }
    }
  }
}

void flap() {
  if (this.gameState == GameState.PLAYING) {
    this.flapRequested = true;
  } else if (this.gameState == GameState.DEAD || this.gameState == GameState.IDLE) {
    this.reset();
  }
}

void update() {
  if (this.gameState == GameState.IDLE) {
    this.idleTime += this.deltaTime;
  } else if (this.gameState == GameState.PLAYING) {
    this.playTime += this.deltaTime;

    var furthestPipeX = 0.0;
    for (var pipe : this.pipes) {
      var pipeXBefore = pipe.getXPosition();
      pipe.updatePosition();
      var pipeXAfter = pipe.getXPosition();
      if (pipeXBefore > this.birdXPos && pipeXAfter <= this.birdXPos) {
        this.score++;
        this.birdXSpeed = min(this.birdXSpeed + this.BIRD_X_SPEED_GAIN, this.BIRD_X_SPEED_MAX);
      }
      var pipeX = pipe.getXPositionRaw();
      if (pipeX > furthestPipeX) {
        furthestPipeX = pipeX;
      }
    }
    for (var pipe : this.pipes) {
      if (pipe.getXPositionRaw() < -this.PIPE_WIDTH) {
        var newPos = furthestPipeX + this.PIPES_HORIZONTAL_DISTANCE;
        pipe.setXPosition(newPos);
        furthestPipeX = newPos;
      }
    }

    if (this.flapRequested) {
      this.flapRequested = false;
      this.birdYSpeed = this.BIRD_FLYUP;
    }

    this.updateBird();

    var dead = this.hitSomething(this.birdXPos, this.birdYPos);
    if (dead) {
      this.gameState = GameState.RAGDOLL;
    }
  } else if (this.gameState == GameState.RAGDOLL) {
    this.ragdollTime += this.deltaTime;

    this.updateBird();
    this.birdXPos += this.birdXSpeed * this.deltaTime / width * height;
    if (this.birdYPos > 1.0 - BOTTOM_HITBOX - BIRD_SIZE) {
      this.birdYPos = 1.0 - BOTTOM_HITBOX - BIRD_SIZE;
      this.gameState = GameState.DEAD;
    }
  }
}

private boolean hitSomething(float x, float y) {
  var hit = y > 1.0 - BOTTOM_HITBOX - BIRD_SIZE;
  for (var pipe : this.pipes) {
    hit |= pipe.testForHit(x, y, this.BIRD_SIZE);
  }
  return hit;
}

private void updateBird() {
  if (this.birdYPos <= this.BIRD_SIZE * 1.05 && this.birdYSpeed < 0 && this.birdYSpeed > this.BIRD_FLYUP * 0.95) {
    this.birdYSpeed = 0.0;
  } else {
    this.birdYSpeed += this.BIRD_FLYDOWN * this.deltaTime;
  }
  this.birdYPos += this.birdYSpeed * this.deltaTime;
  if (this.birdYPos < this.BIRD_SIZE) {
    this.birdYPos = this.BIRD_SIZE;
  }
}

private void generateUI() {
  var buttonStart = new Button(int(0.33 * width), int(0.33 * height), int(0.33 * width), int(0.33 * height), color(224, 225, 64), color(128, 128, 0), "Start", min(0.2 * height, 0.1 * width));
  buttonStart.setAction(new IAction() {
    void execute() {
      reset();
    }
  }
  );
  buttonStart.setCornerRounding(50);
  this.uiElements.add(new GameStateUIElement(buttonStart, GameState.IDLE, GameState.DEAD));
  
  var scoreDisplay = new NumberDisplay(0, int(0.05 * height), width, int(0.1 * height), () -> this.score);
  this.uiElements.add(new GameStateUIElement(scoreDisplay, GameState.PLAYING, GameState.RAGDOLL, GameState.DEAD));
  
  var fpsDisplay = new NumberDisplay(0, 0, int(0.05 * height), int(0.025 * height), () -> int(frameRate));
  this.uiElements.add(new GameStateUIElement(fpsDisplay));
}
