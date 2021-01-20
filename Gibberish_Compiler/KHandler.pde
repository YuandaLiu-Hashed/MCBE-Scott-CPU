void keyPressed() {
  if (keyCode == 0 || keyCode == 17 || keyCode == 18 || keyCode == 157 || keyCode == 16 || keyCode == 768){
    //undefined characters
    if (keyCode == ALT) {
      //SuggesterVisibleToggle = true;
    }
    if (keyCode == CONTROL || keyCode == 157 || keyCode == 768) { //command and control
      keyControl = 0;
    }
    
  } else if (keyCode == TAB) {
    keyTabT = 0;
  } else if (keyCode == 8) {
    keyBackSpaceT = 0;
  } else if (keyCode == UP || keyCode == DOWN || keyCode == LEFT || keyCode == RIGHT) {
    switch (keyCode) {
      case UP:
      keyUpT = 0;
      break;
      case DOWN:
      keyDownT = 0;
      break;
      case LEFT:
      keyLeftT = 0;
      break;
      case RIGHT:
      keyRightT = 0;
      break;
    }
  } else if (keyCode == ENTER || keyCode == RETURN) {
    keyReturnT = 0;
  }
}

void keyTyped() {
  if (key == '\b' || key == '\t' || key == '\n' || key == '\r' || key == '\f' || key == '￿') return;
  if (keyControl == -1) {
    keyTypeTrigger(key);
  } else {
    keyBindingTrigger(key);
  }
}

int keyUpT = -1;
int keyDownT = -1;
int keyLeftT = -1;
int keyRightT = -1;
int keyBackSpaceT = -1;
int keyReturnT = -1;
int keyTabT = -1;

int keyControl = -1;

void keyReleased() {
  if (keyCode == TAB || keyCode == UP || keyCode == DOWN || keyCode == LEFT || keyCode == RIGHT || keyCode == BACKSPACE || keyCode == ENTER || keyCode == RETURN) {
    switch (keyCode) {
      case TAB:
      keyTabT = -1;
      break;
      case UP:
      keyUpT = -1;
      break;
      case DOWN:
      keyDownT = -1;
      break;
      case LEFT:
      keyLeftT = -1;
      break;
      case RIGHT:
      keyRightT = -1;
      break;
      case BACKSPACE:
      keyBackSpaceT = -1;
      break;
      case ENTER:
      case RETURN:
      keyReturnT = -1;
      break;
    }
  }
  
  if (keyCode == CONTROL || keyCode == 157 || keyCode == 768) {
    keyControl = -1;
  }
}

int a = int(2000.0 / frameRate); //after this time, starts repeat (wait time)
int b = int(1700.0 / frameRate); //reset to this time after repeat (difference = reset speed)

void keyUpdate() {
  if (keyTabT != -1) {
    if (keyTabT == 0) {
      keyTabTrigger();
      keyTabT = 1;
    }
  }
  
  if (keyLeftT != -1) {
    if (keyLeftT == 0){
      keyLeftTrigger();
    }
    keyLeftT += 1;
    if (keyLeftT >= a) {
      keyLeftT = b;
      keyLeftTrigger();
    }
  }
  
  if (keyRightT != -1) {
    if (keyRightT == 0){
      keyRightTrigger();
    }
    keyRightT += 1;
    if (keyRightT >= a) {
      keyRightT = b;
      keyRightTrigger();
    }
  }
  
  if (keyUpT != -1) {
    if (keyUpT == 0){
      keyUpTrigger();
    }
    keyUpT += 1;
    if (keyUpT >= a) {
      keyUpT = b;
      keyUpTrigger();
    }
  }
  
  if (keyDownT != -1) {
    if (keyDownT == 0){
      keyDownTrigger();
    }
    keyDownT += 1;
    if (keyDownT >= a) {
      keyDownT = b;
      keyDownTrigger();
    }
  }
  
  if (keyBackSpaceT != -1) {
    if (keyBackSpaceT == 0){
      keyBackSpaceTrigger();
    }
    keyBackSpaceT += 1;
    if (keyBackSpaceT >= a) {
      keyBackSpaceT = b;
      keyBackSpaceTrigger();
    }
  }
  
  if (keyReturnT != -1) {
    if (keyReturnT == 0){
      keyReturnTrigger();
    }
    keyReturnT += 1;
    if (keyReturnT >= a) {
      keyReturnT = b;
      keyReturnTrigger();
    }
  }
}

void keyTabTrigger() {
  if (hasFocusedObject && FocusedObject instanceof CodeBox) {
    CodeBox box = (CodeBox) FocusedObject;
    box.CTab();
  }
}

void keyTypeTrigger(char k){
  if (hasFocusedObject && FocusedObject instanceof CodeBox) {
    CodeBox box = (CodeBox) FocusedObject;
    box.CType(k);
  }
}

void keyUpTrigger() {
  if (hasFocusedObject && FocusedObject instanceof CodeBox) {
    CodeBox box = (CodeBox) FocusedObject;
    box.CUp();
  }
}
void keyDownTrigger() {
  if (hasFocusedObject && FocusedObject instanceof CodeBox) {
    CodeBox box = (CodeBox) FocusedObject;
    box.CDown();
  }
}
void keyLeftTrigger() {
  if (hasFocusedObject && FocusedObject instanceof CodeBox) {
    CodeBox box = (CodeBox) FocusedObject;
    box.CForward();
  }
}
void keyRightTrigger() {
  if (hasFocusedObject && FocusedObject instanceof CodeBox) {
    CodeBox box = (CodeBox) FocusedObject;
    box.CBackward();
  }
}
void keyBackSpaceTrigger() {
  if (hasFocusedObject && FocusedObject instanceof CodeBox) {
    CodeBox box = (CodeBox) FocusedObject;
    box.CBackSpace();
  }
}
void keyReturnTrigger() {
  if (hasFocusedObject && FocusedObject instanceof CodeBox) {
    CodeBox box = (CodeBox) FocusedObject;
    box.CReturn();
  }
}

void keyBindingTrigger(char k){
  if (hasFocusedObject && FocusedObject instanceof CodeBox) {
    CodeBox box = (CodeBox) FocusedObject;
    if (k == 'c') {
      box.copySelection();
    }
    if (k == 'v') {
      box.pasteSelection();
    }
    if (k == 'a') {
      box.selectAll();
    }
  }
}
