module series_2::Series_2

import series_2::Type_I;
import series_2::Type_II;
import series_2::Type_III;
import series_2::Type_IV;
import series_2::Printing;
import analysis::statistics::Descriptive;
import Prelude;
import DateTime;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Prelude;
// and so it begins
// https://www.youtube.com/watch?v=hKN_YFtSFBs

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
	
}


public void getMetrics(bool debug){
	value begintime = now();
	// Don't run on hsqldb right now
	//list[loc] projects = [|project://hsqldb-2.3.1|, |project://JavaTest|, |project://JavaTest2|,|project://smallsql0.21_src|];
	list [loc] projects = [|project://smallsql0.21_src|];

	//list [loc] projects = [|project://testJava|];
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
