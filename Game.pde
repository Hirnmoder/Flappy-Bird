private float lastTime = 0;
private float deltaTime = 0;
private float speed = 1.0;
private boolean debug = false;

private ArrayList<GameStateUIElement> uiElements = new ArrayList<GameStateUIElement>();

private PImage imgUpperPipe;
private PImage imgLowerPipe;
private PImage imgBird;
private PImage imgWing;
private PImage imgBackgroundMain;
private PImage imgBackgroundGround;

private void updateTime() {
  var now = millis() / 1000.0;
  this.deltaTime = (now - this.lastTime) * this.speed;
  this.lastTime = now;
}

void settings() {
  size(1280, 720);
  smooth(4);
}

void setup() {
  windowResizable(true);
  background(0, 0, 0);
  frameRate(120);
  windowTitle("Flappy Bird");
  hint(DISABLE_KEY_REPEAT);

  var font = createFont("PixeloidSans.ttf", 32, false);
  textFont(font);

  try {
    this.loadImages();
    if (this.imgUpperPipe == null ||
      this.imgLowerPipe == null ||
      this.imgBird == null ||
      this.imgWing == null ||
      this.imgBackgroundMain == null ||
      this.imgBackgroundGround == null) {
      this.generateImages();
    }
  }
  catch(Exception e) {
    this.generateImages();
  }

  this.generateUI();
  this.updateTime();
  this.spawnPipes();
}

private void loadImages() {
  this.imgUpperPipe = loadImage("pipe_upper.png");
  this.imgLowerPipe = loadImage("pipe_lower.png");
  this.imgBird = loadImage("bird.png");
  this.imgWing = loadImage("wing.png");
  this.imgBackgroundMain = loadImage("background_main.png");
  this.imgBackgroundGround = loadImage("background_ground.png");
}

private void generateImages() {
  var strokeWidth = 16;
  var pipeWidthPixels = 120;
  var pipeHeightPixels = int((float)pipeWidthPixels / PIPE_WIDTH);

  var upperPipe = createGraphics(pipeWidthPixels, pipeHeightPixels);
  upperPipe.beginDraw();
  upperPipe.stroke(0, 128, 32);
  upperPipe.strokeWeight(strokeWidth);
  upperPipe.fill(96, 255, 128);
  upperPipe.rect(strokeWidth / 2, -strokeWidth/2, pipeWidthPixels - strokeWidth, pipeHeightPixels);
  upperPipe.endDraw();
  this.imgUpperPipe = upperPipe;

  var lowerPipe = createGraphics(pipeWidthPixels, pipeHeightPixels);
  lowerPipe.beginDraw();
  lowerPipe.stroke(0, 128, 32);
  lowerPipe.strokeWeight(strokeWidth);
  lowerPipe.fill(96, 255, 128);
  lowerPipe.rect(strokeWidth/2, strokeWidth/2, pipeWidthPixels - strokeWidth, pipeHeightPixels);
  lowerPipe.endDraw();
  this.imgLowerPipe = lowerPipe;

  var bird = createGraphics(60, 42);
  bird.beginDraw();
  bird.noStroke();
  bird.fill(255, 255, 64);
  bird.circle(30, 21, 60);
  // beak
  bird.stroke(0);
  bird.strokeWeight(4);
  bird.line(45, 17, 60, 30);
  bird.line(45, 25, 60, 30);
  // eye
  bird.fill(0);
  bird.noStroke();
  bird.circle(35, 8, 10);
  bird.endDraw();
  this.imgBird = bird;

  var wing = createGraphics(28, 20);
  wing.beginDraw();
  wing.noStroke();
  wing.fill(192, 64, 128);
  wing.circle(18, 10, 20);
  wing.triangle(18, 0, 0, 10, 18, 20);
  wing.endDraw();
  this.imgWing = wing;

  var bgMain = createGraphics(50, 100);
  bgMain.beginDraw();
  bgMain.background(120, 196, 209);
  bgMain.endDraw();
  this.imgBackgroundMain = bgMain;

  var bgGround = createGraphics(50, 20);
  bgGround.beginDraw();
  bgGround.background(128, 64, 32);
  bgGround.endDraw();
  this.imgBackgroundGround = bgGround;
}


void draw() {
  this.updateTime();

  if (Keyboard.isPressed(ENTER, false) || Keyboard.isPressed(RETURN, false) || Keyboard.isPressed(UP, true) || Keyboard.isPressed(' ', false)) {
    this.flap();
  }
  this.speed = Keyboard.isPressed(SHIFT, true) ? 0.25 : 1.0;
  this.debug = Keyboard.isPressed('d', false);
  this.score += Keyboard.isPressed('w', false) ? 1 : 0;


  this.handleUI();
  this.update();

  this.drawBackgroundMain();
  this.drawPipes();
  this.drawBackgroundGround();
  this.drawBird();
  //this.drawScore();

  if (this.debug) {
    this.drawDebug();
  }

  this.drawUI();
}

void windowResized() {
  this.spawnPipes();
  this.uiElements.clear();
  this.generateUI();
}

private void handleUI() {
  for (var ui : this.uiElements)
    ui.handle(this.gameState);
}

private void drawUI() {
  for (var ui : this.uiElements) {
    ui.draw();
  }
}

void keyPressed() {
  Keyboard.handleKeys(true, key, keyCode);
}
void keyReleased() {
  Keyboard.handleKeys(false, key, keyCode);
}
