
char[] specialCharC = {' ',',',';','(',')'};
int[]  specialCharT = {0  ,1  , 1 ,10 ,11 };

int checkCharacterType(char c) {
  for(int i = 0; i < specialCharC.length; i++) {
    if (specialCharC[i] == c) {
      return specialCharT[i];
    }
  }
  return -1;
}

ArrayList<String> phraseLine(String line, boolean flat) { //WSS: with structure support
  ArrayList<String> phrasedLine = new ArrayList<String>();
  
  String lastPhrase = "";
  
  int countingIndex = 0;
  
  for(int i = 0; i < line.length(); i++) {
    char currentChar = line.charAt(i);
    int charType = checkCharacterType(currentChar);
    
    //if not special, add to the last phrase
    if (charType == -1) {
      lastPhrase += currentChar;
    }
    
    //if comma, conclude the last then add just itself
    if (charType == 1) {
      if (lastPhrase.length() > 0) {
        phrasedLine.add(lastPhrase);
      }
      lastPhrase = "";
      phrasedLine.add("§" + (countingIndex - 1) + currentChar);
    }
    
    //if left bracket '(', conclude itself plus the last
    if (charType == 10) {
      if (lastPhrase.length() > 0) {
        phrasedLine.add(lastPhrase);
      }
      
      if (flat) phrasedLine.add("§" + countingIndex);
      else phrasedLine.add("§_");
      
      countingIndex ++;
      lastPhrase = "";
    }
    
    //if left bracket ')', conclude last then add just itself
    if (charType == 11) {
      if (lastPhrase.length() > 0) {
        phrasedLine.add(lastPhrase);
      }
      countingIndex --;
      
      if (flat) phrasedLine.add("§" + countingIndex);
      else phrasedLine.add("§_");
      
      lastPhrase = "";
    }
    
    //if space bar, conclude last
    if (charType == 0) {
      if (lastPhrase.length() > 0) {
        phrasedLine.add(lastPhrase);
      }
      lastPhrase = "";
    }
  }
  
  if (lastPhrase.length() > 0) {
    phrasedLine.add(lastPhrase);
  }
  
  while (countingIndex > 0) {
    countingIndex --;
    if (flat) phrasedLine.add("§" + countingIndex);
    else phrasedLine.add("§_");
  }
  
  return phrasedLine;
}

class InstructionStructure {
  
  ArrayList<String> segments = new ArrayList<String>();
  int level;
  
  ArrayList<InstructionStructure> childrens = new ArrayList<InstructionStructure>();
  
  InstructionStructure(ArrayList<String> inputSegments, int level) {
    this.level = level;
    
    //deduct structure
    boolean onField = false;
    ArrayList<String> lastFieldSegments = new ArrayList<String>();
    
    int fieldCounter = 0;
    
    //loop though all segments
    for(String thisSegment: inputSegments) {
      int segmentLength = thisSegment.length();
      
      if (!onField) { //not on field
        //if start with §
        if (thisSegment.charAt(0) == '§' && segmentLength >= 2) {
          //if it is a §x where x == this level, set onField and record this field on host
          if (Character.getNumericValue(thisSegment.charAt(1)) == level && segmentLength == 2) {
            onField = true;
            segments.add(thisSegment);
          }
        } else {
          //if it is a just a plain segment, record on host
          segments.add(thisSegment);
        }
      } else { //onfield
        //if it is a §
        if (thisSegment.charAt(0) == '§' && segmentLength >= 2) {
          //if it is a § and on this level, end the record and create another layer with record
          if (Character.getNumericValue(thisSegment.charAt(1)) == level) {
            //end of field
            onField = false;
            
            segments.add("#" + fieldCounter);
            fieldCounter ++;
            segments.add(thisSegment);
            //generate new layer (structure)
            InstructionStructure newLayer = new InstructionStructure(lastFieldSegments, level + 1);
            childrens.add(newLayer);
            lastFieldSegments = new ArrayList<String>();
            
            //if it is a comma, start another field.
            if (segmentLength == 3) {
              if (thisSegment.charAt(2) == ',') {
                //end of field and started another one
                onField = true;
              }
            }
          } else { 
            //if it is a § but not in this level, record to record
            lastFieldSegments.add(thisSegment);
          }
        } else { 
          // not on field, record to record
          lastFieldSegments.add(thisSegment);
        }
      }
    }
    
    println("function: " + segments + " initilized, at layer " + level);
  }
  
  void resolveGeneralStructure() {
    //loop through all possible functions
    for(FunctionReference func: functionReference) {
    }
  }
}
