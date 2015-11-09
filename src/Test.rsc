module Test

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import IO;
import Prelude;
import ListRelation;
import lang::java::m3::AST; 


private str startComment = "//";
private str startMultiLineComment = "/*";
private str javaDocLineComment = "*";
private str endMultiLineComment = "*/";

//...incomplete
//doesnt not work well for multiline comments
private bool isComment(str l){
	 return (startsWith(l, startComment) || startsWith(l, startMultiLineComment)
				  || startsWith(l, javaDocLineComment) || startsWith(l, endMultiLineComment)|| endsWith(l, endMultiLineComment));
}

public int calcLoc(loc fileLocation) {
	int n = 0;
	bool m = false;
	fileLines = readFileLines(fileLocation);
	for(actualLine <- fileLines){
		line = trim(actualLine);	

		if(!isEmpty(line) && !isComment(line)) {
			n += 1;
		}
	}
	return n;	
}

public int calcMethodCC(methodAST){
	int i = 1;
	visit(methodAST){
		case "if"(_, _) : i = i +1;
		case "if"(_, _,_) : i = i +1;
		case "do"(_, _,_) : i = i +1;
		case "conditional"(_, _,_) : i = i +1;
		case "while"(_, _) : i = i +1;
		case "for"(_, _, _) : i = i +1;
		case "for"(_, _, _, _) : i = i +1;
		case "foreach"(_, _, _) : i = i +1;
		case "try"(_, _) : i = i +1;
		case "try"(_, _, _) : i = i +1;
		case "case"(_) : i = i +1;
		case "defaultCase"() : i = i +1;
		case "infix"(_,"&&",_) : i = i +1;
		case "infix"(_,"||",_) : i = i +1;
	}
	return i;
} 

public value calcCC(loc location){
	 model = createM3FromEclipseProject(location);
	 return for(m <- methods(model)){
	 	methodAST = getMethodASTEclipse(m,model=model);
	 	append <m,calcMethodCC(methodAST)>;
	 }
}
public value calcMethodLoc(loc location){
	 model = createM3FromEclipseProject(location);

	 return for(m <- methods(model)){
	 	append <m, calcLoc(m)>;
	 }
}
private list[str] handleMultiline (list[str] l){

}
public value calcClassLoc(loc location){
	 int n = 0;
	 model = createM3FromEclipseProject(location);
	 for(c <- classes(model)) n += calcLoc(c);
	 return n;
}

test bool mt(){
	 loc fileLocation = |project://testJava/|;
	 iprintln(calcMethodLoc(fileLocation));
	 return true;
}
test bool aNoComment(){
	 loc fileLocation = |project://testJava/src/testJava/A.java|;
	 fileLines = readFileLines(fileLocation);
	 return size(fileLines) == calcLoc(fileLocation);
}

test bool a2WithComment(){
	 loc fileLocation = |project://testJava/src/testJava/A2.java|;
	 fileLines = readFileLines(fileLocation);
	 return size(fileLines)-1 == calcLoc(fileLocation);
}
test bool a3MultiLine(){
	 loc fileLocation = |project://testJava/src/testJava/A3.java|;
	 fileLines = readFileLines(fileLocation);
	 return size(fileLines)-3 == calcLoc(fileLocation);
}
test bool a4MultiLine(){
	 loc fileLocation = |project://testJava/src/testJava/A4.java|;
	 fileLines = readFileLines(fileLocation);
	 return size(fileLines)-3 == calcLoc(fileLocation);
}
test bool aEmptyLines(){
	 loc fileLocation = |project://testJava/src/testJava/A5.java|;
	 fileLines = readFileLines(fileLocation);
	 return size(fileLines)-2 == calcLoc(fileLocation);
}
