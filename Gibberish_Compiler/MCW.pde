// Machine Code Window
class MachineCodeBox extends screenObject {

  ArrayList<String> MachineCodeReference = new ArrayList<String>();
  ArrayList<String[]> MachineCode = new ArrayList<String[]>();
  float alignmentOffset = -fontHeight/2;
  
  MachineCodeBox() {
    updateSize();
    CO = new clickableObject(Position, Size);

    updateDisplayContent();
  }

  void updateSize() {
    Position = new CGPoint(screenSize.x - 200, 30);
    Size = new CGSize(180, screenSize.y - 30);
    
    if (CO != null) {
      CO.Position = Position;
      CO.Size = Size;
    }
  }

  void render() {
    super.render();
    
    pushMatrix();
    translate(Position.x, Position.y);
    
    fill(secondaryBackground);
    rect(10,0,Size.x-10,Size.y);
    
    textFont(monoFont14, fontSize);

    //alighment position
    float textStartOffset = fontHeight;
    float selectedLinePosition = editor.curserY * fontHeight - fontHeight/2;
    float selectedMachineCodePosition = -1;

    //front stuff
    float textOffset = textWidth("000 00") + 20;
    fill(grayBackground);
    noStroke();
    rect(0, -1, textOffset - 9, Size.y);

    //display
    pushMatrix();
    translate(0, textStartOffset - editor.scrollBar.scrollPosition + alignmentOffset);

    fill(seperator);
    noStroke();
    rect(0, -1, Size.x, 1);

    int mahcineCodeLineCounter = 0;
    for (int i = 0; i < MachineCode.size(); i++) {
      String[] binaries = MachineCode.get(i);

      //display selection shape
      if (editor.CO.Clicked && editor.curserY == i) {
        float displayheight = binaries.length == 0 ? 3 : fontHeight * binaries.length;
        noStroke();
        fill(color(230, 230, 235));
        rect(0, fontHeight * mahcineCodeLineCounter + 3, Size.x, displayheight);
        //register position for left-right alignment
        selectedMachineCodePosition = fontHeight * mahcineCodeLineCounter + displayheight/2;
      }

      //display lable
      fill(focused ? color(0, 0, 0) : label);
      for (int d = 0; d < binaries.length; d++) {
        text(binaries[d], textOffset, fontHeight * mahcineCodeLineCounter + fontHeight);
        mahcineCodeLineCounter ++;
      }
    }
    fill(seperator);
    noStroke();
    rect(0, mahcineCodeLineCounter * fontHeight + 6, Size.x, 1);

    //line indicator
    for (int i = 0; i < mahcineCodeLineCounter; i++) {
      //line number
      fill(secondaryLabel);

      String lineHex = Integer.toHexString(i);
      if (lineHex.length() == 1) lineHex = "0"+lineHex;

      String lineNumber = Integer.toString(i);
      if (lineNumber.length() == 1) lineNumber = "0"+lineNumber;
      if (lineNumber.length() == 2) lineNumber = "0"+lineNumber;

      text(lineHex + " " + lineNumber, 5, fontHeight + i * fontHeight);
    }

    popMatrix();
    
    fill(seperator);
    rect(0, 0, 1, Size.y);
    rect(Size.x - 1, 0, 1, Size.y);
    
    popMatrix();
    //alighment
    if (selectedMachineCodePosition != -1) {
      float a = min(selectedMachineCodePosition - selectedLinePosition, fontHeight);
      float difference = alignmentOffset + a;
      if (abs(difference) > 0.1) {
        alignmentOffset += difference * -0.1;
      }
    }
  }

  void updateDisplayContent() {
    MachineCodeReference = compiler.machineCode;
    MachineCode.clear();
    for (int i = 0; i < MachineCodeReference.size(); i++) {
      String MCodeLine = MachineCodeReference.get(i);
      if (MCodeLine.length() != 0) {
        String[] MCodeSplit = MCodeLine.split(" ");
        MachineCode.add(MCodeSplit);
      } else {
        String[] empty = {};
        MachineCode.add(empty);
      }
    }
  }
}
