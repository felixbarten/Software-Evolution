module series_1::Series_1

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import series_1::LOC;
import series_1::MComplexity;
import series_1::UnitSize;
import series_1::Duplication;
import Prelude;
import series_1::Scoring;
import series_1::Util;
import series_1::Printing;
import Set;
import DateTime;

public void setup(loc project, bool debug, loc logfile) {
	datetime begintime = now();
	myModel = createM3FromEclipseProject(project);
	list[loc] parsed = [];
	totalLOC = 0;
	containmentLocs = ();
	appendToFile(logfile, "\<h1\>Results for project: <project>\</h1\>");
	
	// start LOC
	datetime beginLOC = now();
	println("Starting LOC calculation");
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
	
	//Display LOC results
	iprintln("Total LOC: <totalLinesOfCode>");
	iprintln("Total Blank lines: <totalBlankLines>");
	iprintln("Total Comments: <totalComments>");
	scoreV = printVerdict(calcLOCScore(totalLinesOfCode));
 	Duration CCDuration = createDuration(beginLOC, now());
	printMetricCalculationTime(executionTime, "Lines Of Code", logfile);	
 	iprintln("Volume Category for project:  <totalLinesOfCode>(<scoreV>)");
	printLOC(containmentLocs, logfile);
	// end LOC
	
	// start Unit Size
	datetime beginUnitSize = now();
	println("Starting Unit Size calculation");
	// calculate unit size
	unitsizes = getUnitsSize(myModel, totalLinesOfCode, debug);
	Duration CCDuration = createDuration(beginUnitSize, now());
	printMetricCalculationTime(executionTime, "Unit Size", logfile);
 	iprintln("Unit Size Category for project: <unitsizes[0]>");
 	printUnitSize(unitsizes, logfile);
	// end Unit Size

	/*
	//start Duplication
	datetime beginDuplication = now();
	println("Starting Code duplication");
 	// Calculate Code Duplication	
 	duplicates = getDuplicates(myModel, unitsizes[1], debug, totalLinesOfCode);
 	scoreDup = printVerdict(calcDuplicationScore(duplicates[0]));
 	Duration CCDuration = createDuration(beginDuplication, now());
	printMetricCalculationTime(executionTime, "Duplication", logfile);
 	iprintln("Code Duplication Category: <scoreDup>");
 	printDuplication(duplicates, logfile);
 	// end Duplication
 	*/
 	
 	// start CC
 	datetime beginCC = now();
 	println("Starting Cyclomatic Complexity");
 	//Calcute Mcabe CC
    cc =  calcCCScore(myModel, totalLinesOfCode);
    scoreCC = printVerdict(cc[0]);
    Duration CCDuration = createDuration(beginCC, now());
	printMetricCalculationTime(executionTime, "Cyclomatic Complexity", logfile);
 	iprintln("MCabe Cyclomatic Complexity Category: <scoreCC>");
 	iprintln("Top 3 Methods CC: <take(3,cc[1])>");
 	printComplexity(cc, logfile);
	// end CC
 	
 	
 	Duration executionTime = createDuration(begintime, now());
	printExecutionTime(executionTime, logfile);
}

public void getMetrics(bool debug){
	value begintime = now();
	// Don't run on hsqldb right now
	list[loc] projects = [|project://hsqldb-2.3.1|, |project://JavaTest|, |project://JavaTest2|,|project://smallsql0.21_src|];

	//list[loc] projects = [|project://RascalTestProject|, |project://JavaTest2|, |project://smallsql0.21_src|];
	//list[loc] projects = [|project://RascalTestProject|, |project://JavaTest2|];
//	list[loc] projects = [|project://RascalTestProject|, |project://JavaTest2|, |project://smallsql0.21_src|];
//	list[loc] projects = [|project://testJava|];

	println("Starting metrics analysis on <size(projects)> projects");
	logfile = startReport();
	
	for (project <- projects) {
		println("Analyzing project <project>");
		setup(project, debug, logfile);
	}
	value endtime = now();
	Duration executionTime = createDuration(begintime,endtime);
	printExecutionTime(executionTime, logfile);
	endReport(logfile);
	
}
