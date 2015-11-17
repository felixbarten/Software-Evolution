module series_1::LOC

import IO;
import Exception;
import List;

public tuple[int,int,int] getLOC(loc location, bool debug) {
	int LOC = 0;
	int blankLines = 0;
	int comments = 0;
	bool incomment = false; 
	
	srcLines = readFileLines(location); 	
	for (line <- srcLines) {	
		if (/^\s*\/\/\s*\w*/ := line) {
			if (debug)
				println("single line comment: <line>");
			comments += 1;
		} else if (/((\s*\/\*[\w\s]+\*\/)+[\s\w]+(\/\/[\s\w]+$)*)+/ := line) {
			if (debug) {
				println("multiline and code intertwined: <line>");
			}
			LOC += 1;
			
		}else if (/^\s*\/\*\*?[\w\s\?\@]*\*\/$/ := line) {
			if (debug)
				println("single line multiline:  <line>");
			comments += 1;
		}  else if (/\s*\/\*[\w\s]*\*\/[\s\w]+/ := line) {
			if (debug)
				println("multiline with code: <line>");
			LOC += 1;
		}	else if (/^[\s\w]*\*\/\s*\w+[\s\w]*/ := line) {
			// end of multiline + code == loc
			if (debug) {
				println("end of multiline + code:  <line>");
			}
			incomment = false; 
			LOC += 1;
		}	else if (/^\s*\/\*\*?[^\*\/]*$/ := line){
			incomment = true;
			comments += 1;
			if (debug)
				println("start multiline comment:  <line>");
				
		} else if (/\s*\*\/\s*$/ := line){
			if (debug)
				println("end multiline comment: <line>");
			comments += 1;
			incomment = false;
				
		} else if (/^\s*$/ := line) {
			blankLines += 1;
		} else {
			if (!incomment) {
				if (debug)
					println("code: <line>");
				LOC += 1;
			} else {
				if (debug)
					println("comment: <line>");
				comments += 1;
				}
			}
			
		}
	if (debug) {
		println("Results for file: <file>");
		println("Lines of Code: <LOC>");
		println("Commented lines: <comments>");
		println("Blank lines: <blankLines>");
	}
	return <LOC,blankLines,comments>;
}

/*
	We use the following values(KLOC) from the SIG paper to grade this(descending):
	0-66
	66-246
	246-665
	665-1310
	>1310
	
*/
public int calcLOCScore(int LOCs){
	int kloc = 1000;
	int result;
	
	if(LOCs < 66*kloc){
		result = 5;	
	} else if (LOCs > 66*kloc && LOCs <= 246*kloc){
		result = 4;
	} else if (LOCs > 246*kloc && LOCs <= 665*kloc){
		result = 3;
	} else if (LOCs > 665*kloc && LOCs <= 1310*kloc){
		result = 2;
	} else if (LOCs > 1310*kloc){
		result = 1;
	} else { //Error
		result = -1;
	}
 	return result;
}
test bool aNoComment(){
	 loc fileLocation = |project://testJava/src/testJava/A.java|;
	 fileLines = readFileLines(fileLocation);
	 return size(fileLines) == getLOC(fileLocation, false)[0];
}

test bool a2WithComment(){
	 loc fileLocation = |project://testJava/src/testJava/A2.java|;
	 fileLines = readFileLines(fileLocation);
	 return size(fileLines)-1 == getLOC(fileLocation, false)[0];
}
test bool a3MultiLine(){
	 loc fileLocation = |project://testJava/src/testJava/A3.java|;
	 fileLines = readFileLines(fileLocation);
	 return size(fileLines)-3 == getLOC(fileLocation, false)[0];
}
test bool a4MultiLine(){
	 loc fileLocation = |project://testJava/src/testJava/A4.java|;
	 fileLines = readFileLines(fileLocation);
	 return size(fileLines)-7 == getLOC(fileLocation, false)[0];
}
test bool aEmptyLines(){
	 loc fileLocation = |project://testJava/src/testJava/A5.java|;
	 fileLines = readFileLines(fileLocation);
	 return size(fileLines)-4 == getLOC(fileLocation, false)[0];
}