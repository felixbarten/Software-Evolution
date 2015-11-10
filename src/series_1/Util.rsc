module series_1::Util
import String;

private str escapeName(str s){
 return replaceFirst(escape(s,("/": ".", "(": "", ")": "")),".","");
}

public str methodName(str name){
 result = escapeName(name); 
 return substring(result, findLast(result,".") + 1);
}

public str methodFullName(str name){
 result = escapeName(name);
 res = methodName(name);  
 return "(" + substring(result,0, findLast(result,".")) +") "+ res;
}