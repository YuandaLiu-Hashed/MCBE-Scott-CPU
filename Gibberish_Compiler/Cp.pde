String fieldStartingSignal = "(:,";
String fieldEnddingSignal = ",)";
String[] unreconizeInstructionResponse = {
  "Please clear your mind before coding (meditation is recommended)",
  "What are you writing? I don't understand this $hit",
  "What is this? I don't understand",
  "Is your keyboard broken or you are broken?",
  "this is wrong, worth Nzero point",
  "I am disappointed",
  "Please learn more before spit gibberish at me",
  "Please obtain some brain cells", 
  "look at this ... no words"
};

class Compiler {
  ArrayList<String> text = new ArrayList<String>();
  ArrayList<String> machineCode = new ArrayList<String>();
  
  boolean onEdit = false;
  
  String errorText = "hello";

  void updateCompiler(ArrayList<String> t) {
    text = t;
  }

  void runCompiler() {
    if (hasFileOpened) Save();
    errorText = "";
    compile();
  }
  
  ArrayList<TracingVariable> tracingVariables = new ArrayList<TracingVariable>();
  
  void compile() {
    machineCode = new ArrayList<String>();
    tracingVariables = new ArrayList<TracingVariable>();
    
    //compile for each line seperately
    for(int i = 0; i < text.size(); i++) {
      String line = text.get(i);
      String mCode = compileLine(line);
    }
  }
  
  String compileLine(String line) {
    //phrase a single line
    ArrayList<String> phrasedLine = phraseLine(line, true);
    
    println(phrasedLine);
    
    InstructionStructure instructionStructure = new InstructionStructure(phrasedLine, 0);
    
    println();
    
    return "";
  }
}
