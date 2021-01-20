private JSONArray jFunctions;
private JSONArray jDataTypes;

ArrayList<FunctionReference> functionReference = new ArrayList<FunctionReference>();
IntDict typeReference = new IntDict();

String baseURL = "Language Reference/";


void LoadLanguageReference() {
  jFunctions = loadJSONArray(baseURL + "functions.json");
  jDataTypes = loadJSONArray(baseURL + "dataTypes.json");
  
  interpreteJson();
}

void interpreteJson() {
  functionReference = new ArrayList<FunctionReference>();
  for(int i = 0; i < jFunctions.size(); i++) {
    JSONObject jsonReference = jFunctions.getJSONObject(i);
    functionReference.add(new FunctionReference(jsonReference));
  }
  
  for(int i = 0; i < jDataTypes.size(); i++) {
    JSONObject jsonReference = jDataTypes.getJSONObject(i);
    typeReference.set(jsonReference.getString("name"), jsonReference.getInt("bit"));
  }
}

class FunctionReference {
  ArrayList<String> syntax;
  int priority;
  String[] output;
  String[][] inputs = {{}};
  String[] compilerMessage;
  String machineCode;
  
  FunctionReference(JSONObject jFunction) {
    syntax = phraseLine(jFunction.getString("syntax"), false);
    priority = jFunction.getInt("priority");
    output = split(jFunction.getString("output"), "-");
    String[] sInputs = split(jFunction.getString("inputs"), ",");
    for(String i: sInputs) {
      String[] eInputs = split(i, "-");
      append(inputs, eInputs);
    }
    compilerMessage = split(jFunction.getString("compiler"), ",");
    machineCode = jFunction.getString("mcode");
  }
}

class TracingVariable {
  String name;
  int typeIndex;
  int ramLocation;
  
  TracingVariable(String name, int typeIndex) {
    this.name = name;
    this.typeIndex = typeIndex;
  }
}
