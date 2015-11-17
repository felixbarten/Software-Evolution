module series_1::Series_1

import series_1::LOC;
import series_1::MComplexity;
import series_1::UnitSize;
import series_1::Duplication;
import series_1::Scoring;
import series_1::Util;
import series_1::Printing;
import series_1::TestCoverage;
import analysis::statistics::Descriptive;
import Prelude;
import Set;
import DateTime;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Prelude;

public void setup(loc project, bool debug, loc logfile) {
	datetime begintime = now();
	datetime modelTime = now();
	myModel = createM3FromEclipseProject(project);
	Duration modelDuration = createDuration(modelTime, now());
	printMetricCalculationTime(modelDuration, "M3 Model Creation", logfile);
	list[loc] parsed = [];
	totalLOC = 0;
	containmentLocs = ();
	appendToFile(logfile, "\<h1\>Results for project: <project.authority>\</h1\>");
	
	// start LOC
	datetime beginLOC = now();
	println("Starting LOC calculation");
	int classesSize = size(classes(myModel));
	int counter = 0;
	for (class <- classes(myModel)) {
		if (counter % 100 == 0) 
			println("Calculated LOC for <counter> out of <classesSize> classes");
		counter += 1; 
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
	volScore = calcLOCScore(totalLinesOfCode);
	scoreV = printVerdict(volScore);
	printLOC(containmentLocs, logfile, project);
 	Duration LOCDuration = createDuration(beginLOC, now());
	printMetricCalculationTime(LOCDuration, "Lines Of Code", logfile);	
	println("");
 	iprintln("Volume Category for project:  <totalLinesOfCode>(<scoreV>)");
	// end LOC
	
	// start Unit Size
	datetime beginUnitSize = now();
	println("");
	println("Starting Unit Size calculation");
	// calculate unit size
	unitsizes = getUnitsSize(myModel, totalLinesOfCode, debug);
	scoreU = printVerdict(unitsizes[0]);
 	iprintln("Unit Size Category for project: <scoreU>");
 	printUnitSize(unitsizes, logfile);
 	Duration UnitSizeDuration = createDuration(beginUnitSize, now());
	printMetricCalculationTime(UnitSizeDuration, "Unit Size", logfile);
	//end Unit Size

	
	//start Duplication
	datetime beginDuplication = now();
	println("");
	println("Starting Code duplication");
 	// Calculate Code Duplication	
 	duplicates = getDuplicates(myModel, unitsizes[1], debug, totalLinesOfCode);
 	dupScore = calcDuplicationScore(duplicates[0]);
 	scoreDup = printVerdict(dupScore);
 	printDuplication(duplicates, logfile);
 	Duration DupDuration = createDuration(beginDuplication, now());
	println("");
 	iprintln("Code Duplication Category: <scoreDup>");
	printMetricCalculationTime(DupDuration, "Duplication", logfile);
 	// end Duplication
 	
 	
 	// start CC
 	datetime beginCC = now();
	println("");
 	println("Starting Cyclomatic Complexity");
 	//Calcute Mcabe CC
    cc =  calcCCScore(myModel, totalLinesOfCode);
    scoreCC = printVerdict(cc[0]);
 	iprintln("MCabe Cyclomatic Complexity Category: <scoreCC>");
 	iprintln("Top 3 Methods CC: <take(3,cc[1])>");
 	
 	iprintln("Total Complexity for project: <(0 | it + i[2] | i <- cc[1])>");
 	printComplexity(cc, logfile, project);
 	Duration CCDuration = createDuration(beginCC, now());
	printMetricCalculationTime(CCDuration, "Cyclomatic Complexity", logfile);
	// end CC
	
	//Calc TestCoverage
	datetime beginTC = now();	
	println("");
 	println("Starting Test Coverage");
 	tc = calcTestCoverage(myModel, totalLinesOfCode);
 	tcs = calcTestCoverageScore(tc);
 	scoreTC = printVerdict(tcs);
 	iprintln("Test Coverage Category: <tc>% (<scoreTC>)");
 	Duration TCDuration = createDuration(beginTC, now());
 	printTestCoverage(tcs, logfile);
	printMetricCalculationTime(TCDuration, "Test Coverage", logfile);
	//end testcoverage
 	
 	
 	//MaintainabilityScore
	println("");
 	println("Maintainability Score:");
	println("");
 	analysability = calcAnalysability(volScore,dupScore,unitsizes[0],tcs); 	
 	iprintln("Analysability: <printVerdict(analysability)>");
 	changeability = calcChangeability(cc[0], dupScore); 	
 	iprintln("Changeability: <printVerdict(changeability)>");
 	stability = calcStability(tcs);
 	iprintln("Stability: <printVerdict(stability)>");
 	testability = calcTestability(cc[0], dupScore, tcs);
 	iprintln("Testability: <printVerdict(testability)>");
 	printMaintainability(analysability, changeability, stability, testability, logfile);
	println("");
	println("Overall score: <printVerdict(toInt(median([analysability, changeability, stability, testability])))>");
 	//end maintainabilitScores
	printEndProject(logfile, project);

 	Duration executionTime = createDuration(begintime, now());
	printProjectExecutionTime(executionTime, logfile);
}

public void getMetrics(bool debug){
	value begintime = now();
	// Don't run on hsqldb right now
	//list[loc] projects = [|project://hsqldb-2.3.1|, |project://JavaTest|, |project://JavaTest2|,|project://smallsql0.21_src|];
	list [loc] projects = [|project://smallsql0.21_src|];

	println("Starting metrics analysis on <size(projects)> projects");
	logfile = startReport(projects);
	
	for (project <- projects) {
		println("Analyzing project <project>");
		setup(project, debug, logfile);
	}
	Duration executionTime = createDuration(begintime, now());
	printExecutionTime(executionTime, logfile);
	endReport(logfile);
	
}
