import java.util.Collections;
import javafx.stage.*;
import javafx.scene.canvas.Canvas;
PFont monoFont14;
PFont displayFont50;

ArrayList<screenObject> objects = new ArrayList<screenObject>();
boolean updateZOrder = true;

color background = color(255, 255, 255);
color titleBarColor = color(255, 255, 255);//dynamic
color secondaryBackground = color(246, 246, 247);
color tertiaryBackground = color(239, 239, 239);
color DarkButtonBackground = color(208, 208, 208);//dynamic
color ButtonBackground = color(239, 239, 239);//dynamic
color selectionBackground = color(32, 89, 201);
color errorBackground = color(255, 0, 0, 60);
color currentLineTintBackground = color(0, 20, 80, 10);
color selectionTintBackground = color(0, 100, 255, 80);

color yellowBackground = color(255, 255, 0);
color grayBackground = color(240, 240, 243);

color seperator = color(213, 213, 213);

color label = color(0);
color secondaryLabel = color(150);
color cyanLabel = color(67, 151, 165);
color greenLabel = color(77, 130, 81);
color magentaLabel = color(169, 60, 128);
color yellowLabel = color(200, 160, 0);
color navyLabel = color(30, 50, 141);

color blueFocus = color(32, 89, 201);
color blueButton = color(32, 89, 201);

CGSize screenSize = new CGSize(1100.0, 700.0);
boolean screenSizeChanged = false;

int compilerWaitTime = 1000;

FrameRateManager frameRateManager = new FrameRateManager();
float frameRate;

CodeBox editor;
Compiler compiler;
MachineCodeBox machineCodeBox;

String appName = "Gibberish Development Kit";
String appVersion = "0.0.2";

void settings() {
  size(1100, 700, FX2D); //P2D FX2D JAVA2D
  pixelDensity(2);
  smooth(2);
}

void setup() {
  setupClipBoard();

  LoadLanguageReference();

  surface.setResizable(true);
  surface.setTitle(appName + " v" + appVersion);
  frameRate(frameRate);
  colorMode(RGB);

  monoFont14 = loadFont("Font/Menlo-Regular-28.vlw");
  displayFont50 = loadFont("Font/SFProText-Light-100.vlw");
  textFont(monoFont14, fontSize);
  fontWidth = textWidth(" ");
  
  //setup compiler
  compiler = new Compiler();
  
  //setup code editor
  editor = new CodeBox();
  objects.add(editor);
  objects.add(editor.scrollBar);
  objects.add(new MenuBar());
  
  //setup codeBox
  machineCodeBox = new MachineCodeBox();
  objects.add(machineCodeBox);
  
  //setup buttons
  objects.add(new AutoCompileButton());
  objects.add(new CompileButton());
  objects.add(new NewButton());
  objects.add(new OpenButton());
  objects.add(new SaveButton());
}

void draw() {
  frameRateManager.computeFramerate();
  frameRate = frameRateManager.frameRate;
  frameRate(frameRate);

  //update screen size if changed
  CGSize currentScreenSize = new CGSize(float(width), float(height));
  if (!currentScreenSize.hasSameValue(screenSize)) {
    screenSize.x = float(width);
    screenSize.y = float(height);
    screenSizeChanged = true;
  } else {
    screenSizeChanged = false;
  }

  titleBarColor = focused ? color(255, 255, 255) : color(244, 244, 244);
  label = focused ? color(0) : secondaryLabel;
  ButtonBackground = focused ? color(239, 239, 239) : color(228, 228, 228);
  DarkButtonBackground = focused ? color(130) : color(200);

  background(255);

  refreshMouse();
  keyUpdate();

  if (screenSizeChanged) {
    for (screenObject i : objects) {
      i.updateSize();
    }
  }

  //Menu Bar
  if (updateZOrder) {
    Collections.sort(objects);
    updateZOrder = false;
  }
  for (screenObject i : objects) {
    i.render();
  }

  surface.setTitle(appName + " v" + appVersion + " - " + (hasFileOpened ? programFile.getName() : "New"));
}
