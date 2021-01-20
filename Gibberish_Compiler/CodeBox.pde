int fontSize = 14; //14
float fontHeight = 18.0; //18
float fontWidth;

class CodeBox extends scrollableObject {
  PShape BoxShape = createShape();
  PShape CurserShape = createShape();
  PShape LineIndicatorShape = createShape();

  int curserPosition = 0;
  int curserY = 0;

  boolean haveSelection = true;
  boolean selectingSelection = false;
  int selectionAnchorPosition = 0;
  int selectionAnchorY = 0;

  int selectionFrontPosition() {
    if (curserY > selectionAnchorY) return selectionAnchorPosition;
    if (curserY < selectionAnchorY) return curserPosition;
    return Math.min(curserPosition, selectionAnchorPosition);
  }
  int selectionFrontY() {
    return Math.min(curserY, selectionAnchorY);
  }
  int selectionBackPosition() {
    if (curserY > selectionAnchorY) return curserPosition;
    if (curserY < selectionAnchorY) return selectionAnchorPosition;
    return Math.max(curserPosition, selectionAnchorPosition);
  }
  int selectionBackY() {
    return Math.max(curserY, selectionAnchorY);
  }

  float curserColorCycle = 0.0;

  float fontWidth = 0.0;
  float textOffset = 0.0;

  int savedCurserPosition = 0;

  ArrayList<String> Text = new ArrayList<String>();

  int lastEdited = -1;

  boolean autoCompile = true;

  void updateSize() {
    
    Position = new CGPoint(0.0, 30.0);
    Size = new CGSize(screenSize.x-200.0, screenSize.y-30.0);
    
    BoxShape = createShape();
    BoxShape.beginShape();
    BoxShape.fill(secondaryBackground);
    BoxShape.vertex(0, 0);
    BoxShape.vertex(0, Size.y);
    BoxShape.vertex(Size.x, Size.y);
    BoxShape.vertex(Size.x, 0);
    BoxShape.endShape(CLOSE);
    BoxShape.setStroke(false);
    
    textOffset = textWidth("000") + 10;
    
    LineIndicatorShape = createShape();
    LineIndicatorShape.beginShape();
    LineIndicatorShape.fill(grayBackground);
    LineIndicatorShape.vertex(0, 0);
    LineIndicatorShape.vertex(0, Size.y-1);
    LineIndicatorShape.vertex(textOffset-4, Size.y-1);
    LineIndicatorShape.vertex(textOffset-4, 0);
    LineIndicatorShape.endShape(CLOSE);
    LineIndicatorShape.setStroke(false);
    
    if (CO != null) {
      CO.Position = Position;
      CO.Size = Size;
    }
  }
    
  CodeBox() {
    super();
    
    CurserShape.beginShape();
    CurserShape.vertex(0, 0);
    CurserShape.vertex(0, fontHeight);
    CurserShape.vertex(0, fontHeight);
    CurserShape.vertex(0, 0);
    CurserShape.endShape(CLOSE);
    CurserShape.setStroke(true);
    CurserShape.setStroke(color(255));
    
    updateSize();
    
    Text.add("");

    CO = new clickableObject(Position, Size);

    fontWidth = textWidth(" ");

    GenericUpdate();
    refreshScrollSize();
  }

  void refreshScrollSize() {
    setScrollSize(fontHeight * Text.size() + 3);
  }

  void render() {

    super.render();

    compiler.onEdit = CO.Clicked;
    
    shape(BoxShape, Position.x, Position.y);
    shape(LineIndicatorShape, Position.x+1, Position.y+1);

    pushMatrix();
    translate(0, -scrollBar.scrollPosition);

    //editing line background
    if (CO.Clicked) {
      fill(currentLineTintBackground);
      noStroke();
      rect(Position.x, Position.y + fontHeight * curserY + 2, Size.x, fontHeight);
    }

    //selection line background 
    if (haveSelection) {

      boolean reverseLoop = curserY < selectionAnchorY;

      for (int line = selectionAnchorY; reverseLoop ? line >= curserY : line <= curserY; line += reverseLoop ? -1 : 1) {
        int leftBound = 0;
        int rightBound = 101;
        if (!reverseLoop && line == selectionAnchorY) leftBound = selectionAnchorPosition;
        if (!reverseLoop && line == curserY) rightBound = curserPosition;
        if ( reverseLoop && line == selectionAnchorY) rightBound = selectionAnchorPosition;
        if ( reverseLoop && line == curserY) leftBound = curserPosition;

        noStroke();
        fill(selectionTintBackground);
        rect(Position.x + leftBound * fontWidth + textOffset, Position.y + line * fontHeight + 1, (rightBound - leftBound) * fontWidth, fontHeight);
        if (leftBound == 0 && selectionAnchorY != curserY) rect(Position.x + textOffset - 3, Position.y + line * fontHeight + 1, 3, fontHeight);
      }
    }

    //curser
    if (haveSelection) {
      if (curserY == selectionAnchorY && curserPosition == selectionAnchorPosition) {
        curserColorCycle = 0.0;
      } else {
        curserColorCycle = 3.0;
      }
    }
    
    if (CO.Clicked) {
      curserColorCycle += 3/frameRate;
      if (curserColorCycle >= 2) {
        CurserShape.setStroke(color(int(curserColorCycle) % 2 == 1 ? color(255, 255, 255, 0) : 0));
      } else {
        CurserShape.setStroke(color(0));
      }
      shape(CurserShape, Position.x + textOffset + 0.1 + fontWidth * curserPosition, Position.y + 20 - fontHeight + curserY * fontHeight);
    } else {
      curserColorCycle = -0.5;
    }

    //error text
    if (!compiler.errorText.equals("")) {
      fill(errorBackground);
      noStroke();
      rect(Position.x, Position.y + fontHeight * (compiler.machineCode.size() - 1) + 2, Size.x, fontHeight);
      fill(255);
      text(compiler.errorText, Position.x + Size.x - textWidth(compiler.errorText) - 10, Position.y + 17 + (compiler.machineCode.size()-1) * fontHeight);
    }

    //display text
    for (int i = 0; i < Text.size(); i++) {
      //line number
      fill(secondaryLabel);
      String lineNumber = Integer.toString(i);
      String line = Text.get(i);
      if (lineNumber.length() == 1) lineNumber = " "+lineNumber;
      if (lineNumber.length() == 2) lineNumber = " "+lineNumber;
      text(lineNumber, Position.x + 5, Position.y + 17 + i * fontHeight);

      //draw text
      fill(label);
      text(line, Position.x + textOffset, Position.y + 17 + i * fontHeight);
    }
    
    popMatrix();

    //curser type
    if (CO.onHover) {
      cursor(TEXT);
    } else {
      cursor(ARROW);
    }

    //forward compiling request
    if (millis() - lastEdited > compilerWaitTime && lastEdited != -1 && autoCompile) {
      compiler.runCompiler();
      machineCodeBox.updateDisplayContent();
      lastEdited = -1;
    }
  }
  
  void compilerCompile() {
    compiler.compile();
    lastEdited = -1;
  }
  
  void removeSelection() {
    
    selectingSelection = false;
    haveSelection = false;
    
    int sfY = selectionFrontY();
    int sfP = selectionFrontPosition();
    int sbY = selectionBackY();
    int sbP = selectionBackPosition();

    String frontLeftover = Text.get(sfY).substring(0, sfP);
    String backLeftover = Text.get(sbY).substring(sbP);
    
    for (int line = sbY; line > sfY; line --) {
      Text.remove(line);
    }
    
    curserY = sfY;
    curserPosition = sfP;
    
    Text.set(sfY, frontLeftover + backLeftover);
  }

  void GenericUpdate() {
    curserColorCycle = 0.0;
    int FirstVisibleLine = int(scrollBar.scrollPosition) / int(fontHeight);
    int LastVisibleLine = int(scrollBar.scrollPosition + Size.y) / int(fontHeight) - 1;
    if (curserY < FirstVisibleLine) scroll((FirstVisibleLine - curserY) * int(fontHeight));
    if (curserY > LastVisibleLine) scroll((curserY - LastVisibleLine) * int(fontHeight));
  }

  void EditingTextUpdate() {
    refreshScrollSize();
    GenericUpdate();
    compiler.updateCompiler(Text);
    savedCurserPosition = curserPosition;
    frameRateManager.wrampUp(30);
    
    haveSelection = false;

    lastEdited = millis();
  }


  void CType(char k) {
    if (haveSelection) removeSelection();

    if (Text.get(curserY).length() != 101) {
      Text.set(curserY, Text.get(curserY).substring(0, curserPosition) + k + Text.get(curserY).substring(curserPosition));
      curserPosition += 1;
    }

    if (curserPosition < Text.get(curserY).length()) {
      if (Text.get(curserY).charAt(curserPosition) == '#') {
        Text.set(curserY, Text.get(curserY).substring(0, curserPosition) + Text.get(curserY).substring(curserPosition + 1));
      }
    }

    EditingTextUpdate();
  }

  void CUp() {
    if (false) { //if showed suggester result
      lastEdited = millis();
      //suggester down
    } else {

      if (haveSelection) {
        haveSelection = false;
        int y = selectionFrontY();
        int p = selectionFrontPosition();
        curserY = y;
        savedCurserPosition = p;
      }

      if (curserY != 0) {
        curserY -= 1;
        curserPosition = min(savedCurserPosition, Text.get(curserY).length());
      } else {
        curserPosition = 0;
        savedCurserPosition = curserPosition;
      }
      GenericUpdate();
    }
  }

  void CDown() {
    if (false) { //if showed suggester result
      lastEdited = millis();
      //suggester down
    } else {

      if (haveSelection) {
        haveSelection = false;
        int y = selectionBackY();
        int p = selectionFrontPosition();
        curserY = y;
        savedCurserPosition = p;
      }

      if (curserY != Text.size() - 1) {
        curserY += 1;
        curserPosition = min(savedCurserPosition, Text.get(curserY).length());
      } else {
        curserPosition = Text.get(curserY).length();
        savedCurserPosition = curserPosition;
      }

      GenericUpdate();
    }
  }

  void CForward() {
    if (haveSelection) {
      haveSelection = false;
      int y = selectionFrontY();
      int p = selectionFrontPosition();
      curserY = y;
      curserPosition = p;
    } else {
      if (curserPosition != 0) {
        curserPosition -= 1;
      } else if (curserY != 0) {
        curserY -= 1;
        curserPosition = Text.get(curserY).length();
      }
    }

    savedCurserPosition = curserPosition;
    GenericUpdate();
  }

  void CBackward() {
    if (haveSelection) {
      haveSelection = false;
      int y = selectionBackY();
      int p = selectionBackPosition();
      curserY = y;
      curserPosition = p;
    } else {
      if (curserPosition != Text.get(curserY).length()) {
        curserPosition += 1;
      } else if (curserY != Text.size() - 1) {
        curserY += 1;
        curserPosition = 0;
      }
    }
    savedCurserPosition = curserPosition;
    GenericUpdate();
  }

  void CBackSpace() {
    if (haveSelection) {
      removeSelection();
    } else {
      if (curserPosition != 0) {
        Text.set(curserY, Text.get(curserY).substring(0, curserPosition-1) + Text.get(curserY).substring(curserPosition));
        curserPosition -= 1;
      } else if (curserY != 0) {
        String previousString = Text.get(curserY);
        Text.remove(curserY);
        curserY -= 1;
        curserPosition = Text.get(curserY).length();
        Text.set(curserY, Text.get(curserY) + previousString);
      }
    }
    
    savedCurserPosition = curserPosition;
    EditingTextUpdate();
  }

  void CReturn() {
    if (haveSelection) removeSelection();
    
    if (false) { //showed suggester
      //trigger suggester
    } else {
      Text.add(curserY+1, Text.get(curserY).substring(curserPosition, Text.get(curserY).length()));
      Text.set(curserY, Text.get(curserY).substring(0, curserPosition));

      curserY += 1;
      curserPosition = 0;

      savedCurserPosition = curserPosition;
      EditingTextUpdate();
    }
  }

  void CTab() {
    
    if (false) { //showed suggester
      //trigger suggester
    }
  }

  void Reset() {
    Text = new ArrayList<String>();
    Text.add("");
    curserPosition = 0;
    curserY = 0;
    haveSelection = false;
    EditingTextUpdate();
  }

  int determineRoll(CGPoint position) {
    float rawY = position.y;
    //determine relative position in textbox
    float relY = rawY - Position.y;
    float textY = relY + scrollBar.scrollPosition - 0; //P2D: -8 FX2D: 0

    int Roll = int(textY/fontHeight);
    if (Roll < 0) Roll = 0;
    if (Roll >= Text.size()) Roll = Text.size() - 1;

    return Roll;
  }

  int determineColumn(CGPoint position, int Roll) {
    float rawX = position.x;
    //determine relative position in textbox
    float relX = rawX - Position.x;
    float textX = relX - textOffset - 0; //P2D: -2.1 FX2D: 0

    float textXTemperary = textX + fontWidth/2;
    int column = int(textXTemperary/fontWidth);
    if (column < 0) column = 0;
    if (column > Text.get(Roll).length()) column = Text.get(Roll).length();

    return column;
  }

  void onClick(CGPoint position) {
    super.onClick(position);
    
    if (!(Position.x < position.x && position.x < Position.x + Size.x && Position.y < position.y && position.y < Position.y + Size.y)) return;

    //compute roll
    int Roll = determineRoll(position);
    curserY = Roll;
    //compute column
    int column = determineColumn(position, Roll);
    curserPosition = column;

    haveSelection = false;

    selectionAnchorY = Roll;
    selectionAnchorPosition = column;

    GenericUpdate();
  }
  
  float automaticScrollingSpeed = 0;
  
  void onDrag(CGPoint position) {
    super.onDrag(position);
    
    haveSelection = true;
    selectingSelection = true;

    int Roll = determineRoll(position);
    int column = determineColumn(position, Roll);

    curserY = Roll;
    curserPosition = column;
    
    float autoScrollMaxSpeed = 100;
    float autoScrollAccelerationPerSecond = 17;
    
    if (position.y >= Position.y + Size.y - 50) {
      automaticScrollingSpeed = Math.max(automaticScrollingSpeed, 0);
      automaticScrollingSpeed = Math.min(automaticScrollingSpeed, autoScrollMaxSpeed);
      automaticScrollingSpeed += autoScrollAccelerationPerSecond/frameRate;
    } else if (position.y <= Position.y + 50) {
      automaticScrollingSpeed = Math.min(automaticScrollingSpeed, 0);
      automaticScrollingSpeed = Math.max(automaticScrollingSpeed, -autoScrollMaxSpeed);
      automaticScrollingSpeed -= autoScrollAccelerationPerSecond/frameRate;
    } else {
      automaticScrollingSpeed = 0;
    }
    
    scroll(automaticScrollingSpeed);
  }

  void onRelease(CGPoint position) {
    onDrag(position);
    super.onRelease(position);
    selectingSelection = false;
    if (curserY == selectionAnchorY && curserPosition == selectionAnchorPosition) {
      haveSelection = false;
    } else {
      haveSelection = true;
    }
  }
  void selectAll() {
    haveSelection = true;
    curserY = 0;
    curserPosition = 0;
    selectionAnchorY = Text.size() - 1;
    selectionAnchorPosition = Text.get(Text.size() - 1).length();
    
  }
  void copySelection() {
    if (!haveSelection || selectingSelection) return;
    
    int sfY = selectionFrontY();
    int sfP = selectionFrontPosition();
    int sbY = selectionBackY();
    int sbP = selectionBackPosition();
    
    if ((sfY == sbY) && (sfP == sbP)) return;
    
    String selectionString = "";
    
    for (int y = sfY; y <= sbY; y ++) {
      String currentLine = Text.get(y);
      String croppedLine = Text.get(y).substring(y == sfY ? sfP : 0, y == sbY ? sbP : currentLine.length());
      selectionString += croppedLine;
      if (y != sbY) selectionString += "\n";
    }
    
    copyToClipboard(selectionString);
  }
  void pasteSelection() {
    String selectionString = getFromClipboard();
    if (selectionString.length() == 0) return;
    for (int i = 0; i < selectionString.length(); i++) {
      char c = selectionString.charAt(i);
      switch (c) {
        case '\n':
        case '\r':
        case '\f':
          CReturn();
        break;
        case '\t':
        break;
        default:
          CType(c);
      }
    }
    
  }
}
