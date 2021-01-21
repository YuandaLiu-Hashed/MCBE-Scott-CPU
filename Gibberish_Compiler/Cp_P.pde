
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
      if (flat) phrasedLine.add("§" + (countingIndex - 1) + currentChar);
      else phrasedLine.add("§_" + currentChar);
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
  
  FunctionReference rFunc;
  ArrayList<String> elements;
  ArrayList<InstructionStructure> nextLayerChildren = new ArrayList<InstructionStructure>();
  boolean isMaster;
  
  
  InstructionStructure(ArrayList<String> inputSegments, boolean isMaster) {
    this.isMaster = isMaster;
    //deduct structure
    deductStructure(inputSegments);
  }
  
  void printStructure(int level) {
    
    printLine(level, true);
    println("function: " + elements);
    
    for(InstructionStructure children: nextLayerChildren) {
      printLine(level + 1, false);
      println();
      children.printStructure(level + 1);
    }
  }
  
  void deductStructure(ArrayList<String> inputSegments) {
    
    /*------------------------*/
    /*        Step One        */
    /*------------------------*/
    
    //println("Input Segment" + inputSegments);
    
    //println("Step 1 Started");
    
    ArrayList<String> preSegments = new ArrayList<String>();
    ArrayList<ArrayList<String>> preChildren = new ArrayList<ArrayList<String>>();
    
    boolean onField = false;
    ArrayList<String> lastFieldSegments = new ArrayList<String>();
    
    //loop though all segments
    for(String thisSegment: inputSegments) {
      int segmentLength = thisSegment.length();
      
      if (!onField) { //not on field
        //if start with §
        if (thisSegment.charAt(0) == '§' && segmentLength >= 2) {
          //if it is a §x where x == this level, set onField and record this field on host
          if (Character.getNumericValue(thisSegment.charAt(1)) == 0 && segmentLength == 2) {
            onField = true;
            preSegments.add("§" + thisSegment.charAt(1));
          }
        } else {
          //if it is a just a plain segment, record on host
          preSegments.add(thisSegment);
        }
      } else { //onfield
        //if it is a §
        if (thisSegment.charAt(0) == '§' && segmentLength >= 2) {
          //if it is a § and on this level, end the record and create another layer with record
          if (Character.getNumericValue(thisSegment.charAt(1)) == 0) {
            //end of field
            onField = false;
            
            preSegments.add("§");
            preSegments.add(thisSegment);
            
            //generate new layer (put into pre children)
            preChildren.add(new ArrayList<>(lastFieldSegments));
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
    
    //println("Step 1 Done");
    //println(" - Presegments: " + preSegments);
    //println(" - PreChildren: " + preChildren);
    //println();
    
    /*------------------------*/
    /*     Relate Funcion     */
    /*------------------------*/
    
    //println("Step 2 Started");
    
    //loop through all possible functions
    ArrayList<FunctionReference> relatedFunctions = new ArrayList<FunctionReference>();
    ArrayList<ArrayList<Integer>> relations = new ArrayList<ArrayList<Integer>>();    
    
    //println("Decoding Structure: " + preSegments);
    
    //loop though all the function reference
    for(FunctionReference func: functionReference) {
      if ( isMaster && func.output.length != 0) continue; //when there is no output, expect no output
      if (!isMaster && func.output.length == 0) continue; //when there is an output, expect an output
      
      ArrayList<String> funcSyntax = func.syntax;
      
      ArrayList<Integer> relation = new ArrayList<Integer>();
      
      int lastTargetTokenIntex = 0;
      boolean matchingStructure = true;
      //loop thuogh all function reference element
      for(int ri = 0; ri < funcSyntax.size(); ri++) {
        String referenceToken = funcSyntax.get(ri);
        
        //if the function reference element is a field, 
        if (referenceToken.charAt(0) == '%' || referenceToken.charAt(0) == '#') {
          lastTargetTokenIntex ++;
          relation.add(-1);
          continue;
        }
        
        boolean foundTi = false;
        //loop though it selves segment and record relation
        for(int ti = lastTargetTokenIntex; ti < preSegments.size(); ti++) {
          String targetToken = preSegments.get(ti);
          String sTargetToken = targetToken;
          if (targetToken.charAt(0) == '§') {
            if (targetToken.length() > 1) {
              //if start with a § and have other characters, it have speical meaning, transfer it to a more generic §_ for compareson
              sTargetToken = "§_" + targetToken.substring(2, targetToken.length());
            } else { 
              //skip if it is a § without special thing (that means it is a reference to its children)
              continue;
            }
          }
          
          //if found the same thing, record it to relation
          if (sTargetToken.equals(referenceToken)) {
            foundTi = true;
            relation.add(ti);
            lastTargetTokenIntex = ti;
            break;
          }
        }
        
        //if nothing found, gave up
        if (!foundTi) {
          matchingStructure = false;
        }
      }
      
      if (matchingStructure && relation.size() > 0) {
        int firstRelation = relation.get(0);
        int lastRelation = relation.get(relation.size() - 1);
        if (firstRelation >= 0 && firstRelation != 0) {
          continue;
        }
        if (lastRelation >= 0 && lastRelation != preSegments.size() - 1) {
          continue;
        }
        
        relatedFunctions.add(func);
        relations.add(relation);
        //println("Found Relation with " + func.syntax);
        //println(" - Relation is: " + relation);
      }
    }
    
    //if no relation, the that's a compile error
    if (relations.size() == 0) {
      println("Function: " + preSegments + " is not decodable");
      elements = preSegments;
      return;
    }
    
    //println("Step 2 Done");
    //println(" - " + relatedFunctions.size() + " relations found");
    //println(" - " + relations.size() + " relations in record");
    //println();
    
    /*------------------------*/
    /*      Match Funcion     */
    /*------------------------*/
    
    //println("Step 3 Started");
    
    //let the definitive function be the function with the highest priority (lowest priority number)
    FunctionReference defFunction = relatedFunctions.get(0);
    ArrayList<Integer> defRelation = relations.get(0);
    
    //find the highest priority
    for(int i = 0; i < relatedFunctions.size(); i++) {
      FunctionReference thisFunction = relatedFunctions.get(i);
      int thisFunctionPriority = thisFunction.priority;
      int lastFunctionPriority = defFunction.priority;
      
      //if last one is more important than this one, make it to the next round
      if (thisFunctionPriority < lastFunctionPriority) {
        defFunction = thisFunction;
        defRelation = relations.get(i);
      }
    }
    
    //println("Function " + defFunction.syntax + "is chosen");
    rFunc = defFunction;
    
    //obtain field
    ArrayList<String> finalSegments = new ArrayList<String>();
    ArrayList<ArrayList<String>> rephrasedChildren = new ArrayList<ArrayList<String>>();
    
    //loop though all preSegment with respect to defFunction and defRelation, and phrase into finalSegments and finalChildrens
    int relationLeftBound = 0;
    for(int i = 0; i < defRelation.size(); i++) {
      String segmentOfRFunction = defFunction.syntax.get(i);
      int segmentIndex = defRelation.get(i);
      
      if (segmentIndex >= 0) { //if segment is not a field, but a legit symbol
        relationLeftBound = segmentIndex + 1;
        finalSegments.add(segmentOfRFunction);
        
      } else { //if segment is a field
        ArrayList<String> child = new ArrayList<String>();
        
        int rightBound = preSegments.size() - 1;
        if (i != defRelation.size() - 1) { //if not last one, check next one
          rightBound = defRelation.get(i + 1) - 1;
        }
        
        for (int e = relationLeftBound; e <= rightBound; e++) {
          String preSegment = preSegments.get(e);
          child.add(preSegment);
        }
        
        finalSegments.add("§");
        rephrasedChildren.add(child);
      }
    }
    
    //println("Step 3 Done");
    //println(" - final segment: " + finalSegments);
    //println(" - rephrased children" + rephrasedChildren);
    //println(" - pre children" + preChildren);
    //println();
    
    /*------------------------*/
    /*  Collapse PreChildren  */
    /*      Consiceness       */
    /*------------------------*/
    
    //println("Step 4 Started");
    
    //substitute preChildren for rephrasedChildren, also create finalChildren
    ArrayList<ArrayList<String>> finalChildren = new ArrayList<ArrayList<String>>();
    int preChildrenCounter = 0;
    for(ArrayList<String> rChild: rephrasedChildren) {
      ArrayList<String> finalChild = new ArrayList<String>();
      if (rChild.size() == 1) { //if size is only one
        String onlyElement = rChild.get(0);
        
        if (onlyElement.equals("§")) { //if is a reference, add the refernece elements
          //add everything from preChildren.get(preChildrenCounter) to finalChild
          for (String preChildrenCounterElement: preChildren.get(preChildrenCounter)) {
            finalChild.add(preChildrenCounterElement);
          }
          preChildrenCounter ++;
        } else {//put whatever in there there
          finalChild.add(onlyElement);
        }
        
      } else {
        for (String rElement: rChild) {
          if (rElement.equals("§")) { //if it is a reference, add the refernece elements and advance counter by one
            for (String preChildrenCounterElement: preChildren.get(preChildrenCounter)) {
              finalChild.add(preChildrenCounterElement);
            }
            preChildrenCounter ++;
          } else {
            finalChild.add(rElement);
          }
        }
      }
      
      //deduct child (reduce parentecies structure)
      if (finalChild.size() >= 3) {
        while (
          finalChild.get(0).length() == 2 && 
          finalChild.get(0).charAt(0) == '§' && 
          finalChild.get(finalChild.size() - 1).length() == 2 && 
          finalChild.get(finalChild.size() - 1).charAt(0) == '§'
        ) {
          //if found things like §0,§0,§0,§0, which means "()()", stop reducing because it will become ")("
          boolean foundOther = false;
          String t = finalChild.get(0);
          for(int i = 1; i < finalChild.size() - 1; i++) {
            if (finalChild.get(i).equals(t)) {
              foundOther = true;
              break;
            }
          }
          if (foundOther) break;
          
          finalChild.remove(0);
          finalChild.remove(finalChild.size() - 1);
        }
      }
      
      finalChildren.add(reduceLevel(finalChild));
    }
    
    //println("Step 4 Done");
    //println(" - final segment: " + finalSegments);
    //println(" - final children" + finalChildren);
    
    elements = finalSegments;
    
    //println();
    //println();
    
    for (ArrayList<String> i: finalChildren) {
      InstructionStructure newChild = new InstructionStructure(i, false);
      nextLayerChildren.add(newChild);
    }
  }
}

ArrayList<String> reduceLevel(ArrayList<String> input) {
  ArrayList<String> returnV = new ArrayList<String>();
  
  int lowestValue = -1;
  
  for(String i: input) {
    if (i.charAt(0) == '§' && i.length() > 1) {
      int nu = Character.getNumericValue(i.charAt(1));
      if (lowestValue == -1) lowestValue = nu;
      
      returnV.add("§" + (Character.getNumericValue(i.charAt(1)) - lowestValue) + i.substring(2, i.length()));
    } else {
      returnV.add(i);
    }
  }
  
  return returnV;
}

void printLine(int count, boolean branch) {
  for (int i = 0; i < count; i++) {
    if (i == count - 1) {
      if (branch) {
        print(" +-");
      } else {
        print(" | ");
      }
    } else {
      print(" |");
    }
  }
}
