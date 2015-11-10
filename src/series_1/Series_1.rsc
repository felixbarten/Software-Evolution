module series_1::Series_1

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import series_1::LOC;
import series_1::MComplexity;
import series_1::UnitSize;
import series_1::Duplication;
import Prelude;
import Set;

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

