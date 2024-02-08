public class Pipe {
  private float x;
  private float yGapCenter;

  public Pipe(float x) {
    this.setXPosition(x);
  }


  public void draw() {
    var pipeHeight = PIPE_WIDTH * height * 160 / 26;
    var drawX = (this.x - PIPE_WIDTH / 2.0) * height;
    var upperY = (this.yGapCenter - PIPE_VERTICAL_GAP / 2.0) * height;
    var lowerY = (this.yGapCenter + PIPE_VERTICAL_GAP / 2.0) * height;
    // upper pipe
    image(imgUpperPipe, drawX, upperY - pipeHeight, PIPE_WIDTH * height, pipeHeight);
    
    // lower pipe
    image(imgLowerPipe, drawX, lowerY, PIPE_WIDTH * height, pipeHeight);
  }

  public void updatePosition() {
    this.x -= birdXSpeed * deltaTime;
  }

  public float getXPositionRaw() {
    return this.x;
  }
  public float getXPosition() {
    return this.x * height / width;
  }

  public void setXPosition(float x) {
    this.x = x;
    this.yGapCenter = random(PIPE_VERTICAL_GAP / 1.5, 1 - PIPE_VERTICAL_GAP / 1.5 - BOTTOM_HITBOX);
  }

  public boolean testForHit(float x, float y, float size) {
    var hw = (float)width / height;
    var hwx = x * hw;
    // first test x coordinate
    var pipeWidthHalf = PIPE_WIDTH / 2.0;
    if (this.x - pipeWidthHalf > hwx + size) {
      return false;
    }
    if (this.x + pipeWidthHalf < hwx - size) {
      return false;
    }

    var dy = abs(this.yGapCenter - y);
    if (hwx <= this.x + pipeWidthHalf && hwx >= this.x - pipeWidthHalf) {
      return dy > PIPE_VERTICAL_GAP / 2.0 - size; // enough clearance top/bottom?
    } else if (dy > PIPE_VERTICAL_GAP / 2.0) {
      return true;  // hit pipe somewhere on the body
    } else {
      // corner case
      var upperY = this.yGapCenter - PIPE_VERTICAL_GAP / 2.0;
      var lowerY = this.yGapCenter + PIPE_VERTICAL_GAP / 2.0;
      var leftX = this.x - pipeWidthHalf;
      var rightX = this.x + pipeWidthHalf;

      if (dist(hwx, y, leftX, upperY) < size) {
        return true;
      } else if (dist(hwx, y, rightX, upperY) < size) {
        return true;
      } else if (dist(hwx, y, leftX, lowerY) < size) {
        return true;
      } else if (dist(hwx, y, rightX, lowerY) < size) {
        return true;
      }
      return false;
    }
  }
}
