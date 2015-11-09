module series_1::Series_1

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Prelude;
import Set;

public void createAST() {
	int LOC = 0;
	//projectAST = createAstsFromEclipseProject(|project://smallsql0.21_src|, true);
	
//	projectAST = createAstsFromEclipseProject(|project://RascalTestProject|, true);
		
	projectAST = createAstsFromEclipseProject(|project://JavaTest2|, true);
	iprintln(projectAST);
	visit (projectAST) {
		case \assert(_): LOC += 1; 
	    case \assert(_, _): LOC += 1; 
	    case \block(_, _): LOC += 1; 
	    case \break() : LOC += 1; 
	    case \break(_) : LOC += 1; 
	    case \continue(): LOC += 1; 
	    case \continue(_): LOC += 1; 
	    case \do(_, _): LOC += 1; 
	    case \empty(): LOC += 1; 
	    case \foreach(_, _, _): LOC += 1; /// declaration?
	    case \for(_, _,_ ,_): LOC += 1; 
	    case \for(_, _, _): LOC += 1; 
	    case \if(_ , _): LOC += 1; 
	    case \if(_ , _, _ ): LOC += 1; 
	    case \label(_, _): LOC += 1; 
	    case \return(_): LOC += 1; 
	    case \return(): LOC += 1; 
	    case \switch(_,_): LOC += 1; 
	    case \case(_): LOC += 1; 
	    case \defaultCase(): LOC += 1; 
	    case \synchronizedStatement(_) : LOC += 1; 
	    case \throw(_) : LOC += 1; 
	    case \try(_, _ ): LOC += 2; 
	    case \try(_ , _, _): LOC += 2;                                       
	    case \catch(_, _): LOC += 2; 			// declaration?
//	    case \declarationStatement(_): LOC += 0; // declaration
	    case \while(_, _): LOC += 1; 
	    case \expressionStatement(_): LOC += 1; 
	    case \constructorCall(_, _,_): LOC += 1; 
	    case \constructorCall(_, _): LOC += 1;
	    //declarations::: 
//		case \compilationUnit(_, _): LOC += 0;
	    case \compilationUnit(_, _, _): LOC += 1;
	    case \enum(_, _, _, _): LOC += 1;
	    case \enumConstant(_, _, _): LOC += 1;
	    case \enumConstant(_, _): LOC += 1;
	    case \class(_, _, _, _): LOC += 2;
	    case \class(_): LOC += 1;
	    case \interface(_, _, _, _): LOC += 1;
	    case \field(_, _): LOC += 1;
	    case \initializer(_): LOC += 1;
	    case \method(_, _, _, _, _): LOC += 0;
	    case \method(_, _, _, _): LOC += 1;
	    case \constructor(_, _, _, _): LOC += 1;
	    case \import(_): LOC += 1;
	    case \package(_): LOC += 1;
	    case \package(_, _): LOC += 1;
	    case \variables(_, _): LOC += 1;
	    case \typeParameter(_, _List): LOC += 1;
	    case \annotationType(_, _): LOC += 1;
	    case \annotationTypeMember(_, _): LOC += 1;
	    case \annotationTypeMember(_, _, _): LOC += 1;
	    case \parameter(_, _, _): LOC += 1;
	    case \vararg(_, _): LOC += 1;
//	    case /\s*}\s*/: LOC +=0;
		default: LOC+= 0;
		
	}
	println("<LOC> after visit");
	
	
	
	LOC = 0;
		
	visit(projectAST) {
		case \Statement: LOC += 1;
		case \Declaration: LOC +=1;
	}
	println("<LOC> after visit");
	
	
	for (/Statement x := projectAST)	{
		//println("Current statement: <x>");

		visit(x){
			case \declarationStatement(_): LOC += 0;
			default: LOC +=1;
		}
		
		/*
		if (Declaration !:= x){
			iprintln("Current decl: <x>");
			LOC += 1;
		} else {
			println("THIS IS S DECLARATION");
		}
		*/	
	}
	println(LOC);
	
	
	for (/Declaration dec := projectAST) {
		LOC += 1;
	}
	println(LOC);	
}

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

public tuple [str, rel[str, int, int]] getUnitsSize(M3 project, int totalLOC) {
	rel[str, int, int] unitSizes = {};
	int moderate = 0;
	int high = 0;
	int simple = 0;
	int vhigh = 0;

	for (method <- methods(project)) {
		LOC = getLOC(method, false)[0];
		category = getMethodLOCCategory(LOC); 
		unit = {<method.path, LOC, category>};
		unitSizes += unit;
		switch(category){
			case 2:
				vhigh += LOC;
			case 3:
				high += LOC;
			case 4:
				moderate += LOC;
			case 5:
				simple += LOC;			
		}
	}
	real percentageModerate = moderate/totalLOC*100.0;
	real percentageHigh = high/totalLOC*100.0;
	real percentageVeryHigh = vhigh/totalLOC*100.0;
	real percentageSimple = simple/totalLOC*100.0;
	str unitSizeCategory = "";
	
	if (percentageModerate <= 25 && percentageHigh == 0 && percentageVeryHigh == 0) {
		unitSizeCategory = "++";
	} else if (percentageModerate > 25 && percentageModerate <= 30 && percentageHigh <= 5 && percentageVeryHigh == 0) {
		unitSizeCategory = "+";
	} else if (percentageModerate > 30 && percentageModerate <= 40 && percentageHigh <= 10 && percentageVeryHigh == 0) {
		unitSizeCategory = "0";
	} else if (percentageModerate > 40 && percentageModerate <= 50 && percentageHigh <= 15 && percentageVeryHigh <= 5) {
		unitSizeCategory = "-";
	} else if (percentageModerate > 50 || percentageHigh > 15 || percentageVeryHigh > 5){
		unitSizeCategory = "--";
	}
	prettyPrintUnitSize(unitSizes); 
	
	return <unitSizeCategory, unitSizes>;
}

public void setup(loc project, bool debug) {
	myModel = createM3FromEclipseProject(project);
	list[loc] parsed = [];
	//myModel = createM3FromEclipseProject(	|project://JavaTest2|);
	///iprintln(myModel);
	///iprintln(myModel@containment);
	totalLOC = 0;
	containmentLocs = ();
	
	for (class <- classes(myModel)) {
		list[loc] units = [c | c <- invert(myModel@containment)[class], c.scheme == "java+compilationUnit"];
		for (loc unit <- units){
			if (debug) 
				iprintln("Parsing: <unit>");
			if (unit notin parsed) {
				containmentLocs += (unit: getLOC(unit, debug));
				parsed += unit;
			}
		}
	}	
	// aggregate results
	totalLinesOfCode = ((0 | it + (containmentLocs[c])[0] | c <- containmentLocs));
	totalBlankLines = ((0 | it + (containmentLocs[c])[1] | c <- containmentLocs));
	totalComments = ((0 | it + (containmentLocs[c])[2] | c <-containmentLocs));
	iprintln("Total LOC: <totalLinesOfCode>");
	iprintln("Total Blank lines: <totalBlankLines>");
	iprintln("Total Comments: <totalComments>");
	
	// calculate unit size
	unitsizes = getUnitsSize(myModel, totalLinesOfCode);
 	iprintln("Unit Size Category for project: <unitsizes[0]>");
 	
 	duplicates = getDuplicates(myModel, unitsizes[1], debug, totalLinesOfCode);
 	iprintln(duplicates);
}

public void prettyPrintUnitSize(rel[str, int, int] unitsizes) {
	iprintln ("Unit Sizes:");
	for (unit <- unitsizes) {
		iprintln("Method: <unit[0]> LOC: <unit[1]> Judgement: <printVerdict(unit[2])>");
	}

}
public str printVerdict(int verdict) {
	str strVerdict = "";
	switch(verdict) {
		case 5: 
			strVerdict = "++";
		case 4: 
			strVerdict = "+";
		case 3: 
			strVerdict = "+/-";
		case 2:
			strVerdict = "-";
		case 1: 
			strVerdict = "--";
		default:
			strVerdict = "unknown";
	}
	return strVerdict;
}

public int getMethodLOCCategory(LOC) {
	if (LOC >= 0 && LOC <= 20) {
		return 5;
	} else if (LOC > 20 && LOC <= 50) {
		return 4;
	} else if (LOC > 50 && LOC <= 100) {
		return 3;
	} else if (LOC > 100) {
		return 2;
	} else {
		// should never reach this
		return 1;
	}
}


public void getMetrics(bool debug){
	// Don't run on hsqldb right now
	//list[loc] projects = [|project://hsqldb-2.3.1|, |project://RascalTestProject|, |project://JavaTest2|,];
	list[loc] projects = [|project://RascalTestProject|, |project://JavaTest2|, |project://smallsql0.21_src|];
	println("Starting metrics analysis on <size(projects)> projects");
	
	for (project <- projects) {
		println("Analyzing project <project>");
		setup(project, debug);
	}

}

public int getDuplicates(M3 model, rel [str, int, int] unitsizes, bool debug, int totalLOC) {
	//list[list[loc]] duplicates = [];
	list[list[str]] duplicateLines = [];
	list[list[str]] duplicateLineSets = [];
	int duplicates = 0;
	for (class <- classes(model)) {
		if (getLOC(class, debug)[0] < 6) {
			continue;
		}
		
		list[str] srcLines = [];
		for (line <- readFileLines(class)) {
			srcLines += trim(line);
		}
		
		int begin = 0;
		int end = 5;
		while (end < size(srcLines)){
			list[str] slice = srcLines[begin..end];

			if (slice in duplicateLines) {
				duplicates += 1;
				duplicateLineSets = push(slice, duplicateLineSets);
				if(end+6 > size(srcLines) -1){
				 end = size(srcLines);
				}else{
					end +=6;	
				}
			} else {
				duplicateLines = push(slice, duplicateLines);
				begin += 1;
				end += 1;
			}
		}
	}
	iprintln(duplicateLineSets);
	println("duplicates <duplicates>");
	real percentageDuplicates = duplicates *6.0 /totalLOC * 100.0;
	iprintln("Percentage of duplications: <percentageDuplicates>%");
	
	return duplicates;
}

