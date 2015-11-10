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

public loc startReport() {
	loc reportFile = |project://SoftwareEvolution/reports/report.html|;
	println("writing report");
	// write or overrwrite file. 
	str msg  = "\<html\>\<body\>";
	
	writeFile(reportFile, msg);	
	return reportFile;	
	
}
public void endReport(loc file) {
	appendToFile(file, "\</body\>\n\</html\>");
}

public void setup(loc project, bool debug, loc logfile) {
	myModel = createM3FromEclipseProject(project);
	list[loc] parsed = [];
	//myModel = createM3FromEclipseProject(	|project://JavaTest2|);
	///iprintln(myModel);
	///iprintln(myModel@containment);
	totalLOC = 0;
	containmentLocs = ();
	appendToFile(logfile, "\<h1\>Results for project: <project>\</h1\>\</br\>");
	
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
	
	printLOC(containmentLocs, logfile);
	
	
	// calculate unit size
	unitsizes = getUnitsSize(myModel, totalLinesOfCode);
 	iprintln("Unit Size Category for project: <unitsizes[0]>");
 	printUnitSize(unitsizes, logfile);
 	
 	duplicates = getDuplicates(myModel, unitsizes[1], debug, totalLinesOfCode);
 	iprintln(duplicates);
}

public void getMetrics(bool debug){
	// Don't run on hsqldb right now
	//list[loc] projects = [|project://hsqldb-2.3.1|, |project://RascalTestProject|, |project://JavaTest2|,];
//	list[loc] projects = [|project://RascalTestProject|, |project://JavaTest2|, |project://smallsql0.21_src|];
	list[loc] projects = [|project://RascalTestProject|, |project://JavaTest2|];

	println("Starting metrics analysis on <size(projects)> projects");
	logfile = startReport();
	
	for (project <- projects) {
		println("Analyzing project <project>");
		setup(project, debug, logfile);
	}
	endReport(logfile);
}


// print methods

public void printLOC(map[loc, tuple[int,int,int]] containmentLocs, loc logfile) {
	// aggregate results
	totalLinesOfCode = ((0 | it + (containmentLocs[c])[0] | c <- containmentLocs));
	totalBlankLines = ((0 | it + (containmentLocs[c])[1] | c <- containmentLocs));
	totalComments = ((0 | it + (containmentLocs[c])[2] | c <-containmentLocs));
	iprintln("Total LOC: <totalLinesOfCode>");
	iprintln("Total Blank lines: <totalBlankLines>");
	iprintln("Total Comments: <totalComments>");
	
	appendToFile(logfile, "\<h2\>Lines of code\</h2\>");
	appendToFile(logfile, "Total LOC: <totalLinesOfCode>\</br\>");
	appendToFile(logfile, "Total Blank lines: <totalBlankLines>\</br\>");
	appendToFile(logfile, "Total Comments: <totalComments>\</br\>");
}
public void printUnitSize(tuple [str, rel[str, int, int]] unitsizes, loc logfile) {
	appendToFile(logfile, "\<h2\>Unit Size per method\</h2\>");
	
	appendToFile(logfile, "\<table style=\"text-align:left;\"\>\<thead\>\<th\>Method Name\</th\>\<th\>LOC\</th\>\<th\>Judgement\>\</thead\>\<tbody\>");
	for (unit <- unitsizes[1]) {
			appendToFile(logfile, "\<tr\>");
			appendToFile(logfile, "\<td\><unit[0]>\</td\>");
			appendToFile(logfile, "\<td\><unit[1]>\</td\>");
			appendToFile(logfile, "\<td\><unit[2]>\</td\>");
			appendToFile(logfile, "\</tr\>");
	}
	appendToFile(logfile, "\</tbody\>\</table\>");
	
	appendToFile(logfile, "\<h2\>Unit Size for project\</h2\>");
	
	appendToFile(logfile, "The unit size for this project was rated \<strong\><unitsizes[0]>\</strong\>");
	
}

public void printComplexity() {
	
}

