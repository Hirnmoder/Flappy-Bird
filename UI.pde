public abstract class UIElement { //<>//
  protected int x;
  protected int y;
  protected int w;
  protected int h;

  protected int mouseAffectionXleft = 0;
  protected int mouseAffectionYtop = 0;
  protected int mouseAffectionXright = 0;
  protected int mouseAffectionYbottom = 0;

  protected boolean visible = true;
  protected boolean invisibleHandleMouse = false;

  protected boolean mouseHover = false;
  protected boolean mouseDownLeft = false;
  protected boolean mouseDownRight = false;

  protected UIElement(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  public void handleMouse() {
    if (this.visible || this.invisibleHandleMouse || this.mouseDownLeft || this.mouseDownRight) {
      var uix = mouseX - this.x;
      var uiy = mouseY - this.y;
      this.setMouseHover(this.isInAffectionRect(uix, uiy));

      var mouseDownLeft = mousePressed && mouseButton == LEFT;
      if (this.mouseDownLeft ^ mouseDownLeft) {
        if (!mouseDownLeft)
          this.handleLeftClick(uix, uiy);
      }
      this.mouseDownLeft = this.mouseHover && mouseDownLeft;

      var mouseDownRight = mousePressed && mouseButton == RIGHT;
      if (this.mouseDownRight ^ mouseDownRight) {
        if (!mouseDownRight)
          this.handleRightClick(uix, uiy);
      }
      this.mouseDownRight = this.mouseHover && mouseDownRight;
    } else {
      this.setMouseHover(false);
    }
  }

  protected void setMouseHover(boolean mouseHover) {
    if (this.mouseHover ^ mouseHover) {
      this.mouseHover = mouseHover;
      if (this.mouseHover)
        this.onMouseEnter();
      else
        this.onMouseLeave();
    }
  }

  protected boolean isInAffectionRect(int uix, int uiy) {
    return uix >= -this.mouseAffectionXleft &&
      uix <= this.w + this.mouseAffectionXright &&
      uiy >= -this.mouseAffectionYtop &&
      uiy <= this.h + this.mouseAffectionYbottom;
  }

  public void draw() {
    if (this.visible) {
      pushMatrix();
      pushStyle();
      translate(this.x, this.y);
      this.drawInternal();
      popStyle();
      popMatrix();
    }
  }

  public int getPositionX() {
    return this.x;
  }
  public int getPositionY() {
    return this.y;
  }
  public void setPositionX(int x) {
    this.x = x;
  }
  public void setPositionY(int y) {
    this.y = y;
  }
  public void setPosition(int x, int y) {
    this.x = x;
    this.y = y;
  }

  public int getWidth() {
    return this.w;
  }
  public int getHeight() {
    return this.h;
  }
  public void setWidth(int w) {
    this.w = w;
  }
  public void setHeight(int h) {
    this.h = h;
  }
  public void setSize(int w, int h) {
    this.w = w;
    this.h = h;
  }
  public void setVisible() {
    this.setVisible(true);
  }
  public void setVisible(boolean visible) {
    this.visible = visible;
  }
  public void setInvisible() {
    this.setVisible(false);
  }

  protected void handleLeftClick(int x, int y) {
  }
  protected void handleRightClick(int x, int y) {
  }
  protected void onMouseEnter() {
  }
  protected void onMouseLeave() {
  }
  protected abstract void drawInternal();
}

public abstract class RectangularUIElement extends UIElement {
  protected color backgroundColor;
  protected color foregroundColor;
  protected float strokeWidth = 5;
  protected float cornerRounding = 0;

  protected RectangularUIElement(int x, int y, int w, int h, color background, color foreground) {
    super(x, y, w, h);
    this.backgroundColor = background;
    this.foregroundColor = foreground;
  }

  public void setBackgroundColor(color bg) {
    this.backgroundColor = bg;
  }
  public color getBackgroundColor() {
    return this.backgroundColor;
  }
  public void setForegroundColor(color fg) {
    this.foregroundColor = fg;
  }
  public color getForegroundColor() {
    return this.foregroundColor;
  }

  public void setStrokeWidth(float strokeWidth) {
    this.strokeWidth = strokeWidth;
  }
  public float getStrokeWidth () {
    return this.strokeWidth;
  }

  public void setCornerRounding(float cornerRounding) {
    this.cornerRounding = cornerRounding;
  }
  public float getCornerRounding() {
    return this.cornerRounding;
  }

  protected void drawInternal() {
    stroke(this.foregroundColor);
    strokeWeight(this.strokeWidth);
    fill(this.backgroundColor);
    rect(0, 0, this.w, this.h, this.cornerRounding);
  }
}


public class Button extends RectangularUIElement {
  protected String text;
  protected float textSize;
  protected IAction action;

  public Button(int x, int y, int w, int h, color background, color foreground, String text, float textSize) {
    super(x, y, w, h, background, foreground);
    this.text = text;
    this.textSize = textSize;
  }

  public void setText(String text) {
    this.text = text;
  }
  public String getText() {
    return this.text;
  }

  public void setTextSize(float textSize) {
    this.textSize = textSize;
  }
  public float getTextSize() {
    return this.textSize;
  }

  public void setAction(IAction action) {
    this.action = action;
  }

  protected void drawInternal() {
    super.drawInternal();
    textSize(this.textSize);
    textAlign(CENTER, CENTER);
    fill(this.foregroundColor);
    text(this.text, this.mouseHover ? int(this.w * 0.025) : 0, this.mouseHover ? int(this.h * 0.025) : 0, this.w, this.h);
  }

  protected void handleLeftClick(int x, int y) {
    if (this.action != null) this.action.execute();
  }

  protected void onMouseEnter() {
    cursor(HAND);
  }
  protected void onMouseLeave() {
    cursor(ARROW);
  }
}

public interface IAction {
  public void execute();
}

import java.util.function.Supplier;

public class NumberDisplay extends UIElement {
  protected Supplier<Integer> getNumber = () -> 0;
  protected PImage[] digits;

  protected final int DIGIT_WIDTH = 14;
  protected final int DIGIT_HEIGHT = 20;

  public NumberDisplay(int x, int y, int w, int h, Supplier<Integer> getNumber) {
    super(x, y, w, h);
    this.getNumber = getNumber;
    this.loadNumbers(loadImage("numbers.png"));
  }

  protected void loadNumbers(PImage fullSprite) {
    this.digits = new PImage[10];
    for (var i = 0; i < 10; i++) {
      var imgDigit = createGraphics(this.DIGIT_WIDTH, this.DIGIT_HEIGHT);
      imgDigit.beginDraw();
      imgDigit.copy(fullSprite, i * this.DIGIT_WIDTH, 0, this.DIGIT_WIDTH, this.DIGIT_HEIGHT, 0, 0, this.DIGIT_WIDTH, this.DIGIT_HEIGHT);
      imgDigit.endDraw();
      this.digits[i] = imgDigit;
    }
  }

  protected void drawInternal() {
    var number = this.getNumber.get();
    pushMatrix();
    translate(this.w / 2.0, this.h / 2.0);
    scale(this.h / (float)this.DIGIT_HEIGHT);
    imageMode(CENTER);

    var numberOfDigits = max(1, ceil(log(number + 1) / log(10)));
    var offset = (numberOfDigits - 1) / 2.0 * this.DIGIT_WIDTH;
    for (var place = numberOfDigits - 1; place >= 0; place--) {
      var digit = int(number / pow(10, place)) % 10;
      image(this.digits[digit], offset - place * this.DIGIT_WIDTH, 0, this.DIGIT_WIDTH, this.DIGIT_HEIGHT);
    }
    popMatrix();
  }
}




public final class GameStateUIElement {
  private UIElement uiElement;
  private GameState[] visibleGameStates;

  public GameStateUIElement(UIElement uiElement) {
    this.uiElement = uiElement;
    this.visibleGameStates = null;
  }

  public GameStateUIElement(UIElement uiElement, GameState visibleGameState) {
    var visibleGameStates = new GameState[1];
    visibleGameStates[0] = visibleGameState;
    this.uiElement = uiElement;
    this.visibleGameStates = visibleGameStates;
  }

  public GameStateUIElement(UIElement uiElement, GameState visibleGameState1, GameState visibleGameState2) {
    var visibleGameStates = new GameState[2];
    visibleGameStates[0] = visibleGameState1;
    visibleGameStates[1] = visibleGameState2;
    this.uiElement = uiElement;
    this.visibleGameStates = visibleGameStates;
  }

  public GameStateUIElement(UIElement uiElement, GameState visibleGameState1, GameState visibleGameState2, GameState visibleGameState3) {
    var visibleGameStates = new GameState[3];
    visibleGameStates[0] = visibleGameState1;
    visibleGameStates[1] = visibleGameState2;
    visibleGameStates[2] = visibleGameState3;
    this.uiElement = uiElement;
    this.visibleGameStates = visibleGameStates;
  }

  public GameStateUIElement(UIElement uiElement, GameState[] visibleGameStates) {
    this.uiElement = uiElement;
    this.visibleGameStates = visibleGameStates;
  }

  public void handle(GameState gameState) {
    if (this.visibleGameStates != null) {
      boolean isVisible = false;
      for (var gs : this.visibleGameStates)
        isVisible |= gs == gameState;
      this.uiElement.setVisible(isVisible);
    }
    this.uiElement.handleMouse();
  }
  public void draw() {
    this.uiElement.draw();
  }
}
