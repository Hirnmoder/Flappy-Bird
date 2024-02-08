public static class Keyboard {
  public static boolean isPressed(int key, boolean coded) {
    return coded ? keysDownCoded[key] : keysDownAscii[key];
  }

  public static void handleKeys(boolean keyPressed, int key, int keyCode) {
    if (key == CODED) {
      if (keyCode < 256)
        keysDownCoded[keyCode] = keyPressed;
    } else {
      if (key < 256)
      {
        if (key >= 'A' && key <= 'Z')
          key += 'a' - 'A';
        keysDownAscii[key] = keyPressed;
      }
    }
    //println("Key " + key + " (" + keyCode + ") " + (keyPressed ? "pressed" : "released"));
  }

  private static boolean[] keysDownCoded = new boolean[256];
  private static boolean[] keysDownAscii = new boolean[256];
}
