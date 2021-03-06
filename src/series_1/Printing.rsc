module series_1::Printing

import Prelude;
import series_1::Duplication;
import series_1::LOC;
import series_1::Scoring;
import series_1::Util;
import analysis::statistics::Descriptive;
import util::Math;


public loc startReport(list[loc] projects) {
	loc logfile = |project://Software-Evolution/reports/report.html|;
	println("writing report");
	// write or overrwrite file. 
	str msg  = "\<html\>\<header\>";
	writeFile(logfile, msg);	
	appendToFile(logfile, "\<link href=\"css/bootstrap.min.css\" rel=\"stylesheet\"\>");
	appendToFile(logfile, "\<link href=\"css/custom.css\" rel=\"stylesheet\"\>");
	
	appendToFile(logfile, "\</header\>\<body\>");
	appendToFile(logfile, "\<script src=\"js/bootstrap.min.js\"\>\</script\>");
	appendToFile(logfile, "\<script src=\"js/d3.min.js\"\>\</script\>");
	appendToFile(logfile, "\<script src=\"js/nvd3.min.js\"\>\</script\>");
	appendToFile(logfile, "\<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js\"\>\</script\>");
	appendToFile(logfile, "\<script\>var projects = {");
	int sizeOf = size(projects) - 1;
	for (project <- projects){
		str projectname = project.authority;
		projectname = replaceAll(projectname, ".", "_");
		if (project == projects[sizeOf]) {
			appendToFile(logfile, "\"<projectname>\": {\"cc\": [], \"cc1\": [], \"loc\": []}");
		} else {
			appendToFile(logfile, "\"<projectname>\": {\"cc\": [], \"cc1\": [], \"loc\": []}, ");
		}
	}
	appendToFile(logfile, "};\</script\> ");
	appendToFile(logfile, "\<div class=\"container\"\>");
	appendToFile(logfile, "\<div class=\"row\"\>");

	return logfile;	
	
}

public void endReport(loc file) {
	appendToFile(file, "\<script src=\"js/graphs.js\"\>\</script\>");

	appendToFile(file, "\</div\>");
	appendToFile(file, "\</body\>\n\</html\>");
}


public void printLOC(map[loc, tuple[int,int,int]] containmentLocs, loc logfile, loc project) {
	// aggregate results
	totalLinesOfCode = ((0 | it + (containmentLocs[c])[0] | c <- containmentLocs));
	totalBlankLines = ((0 | it + (containmentLocs[c])[1] | c <- containmentLocs));
	totalComments = ((0 | it + (containmentLocs[c])[2] | c <-containmentLocs));
	
	appendToFile(logfile, "\<h2\>Lines of code\</h2\>");
	appendToFile(logfile, "Total LOC: <totalLinesOfCode>\</br\>");
	appendToFile(logfile, "Total Blank lines: <totalBlankLines>\</br\>");
	appendToFile(logfile, "Total Comments: <totalComments>\</br\>");
	
	appendToFile(logfile, "\<table style=\"width: 1200px;word-wrap: break-word;table-layout:fixed;\" class=\"table table-striped table-bordered\" \>");
	appendToFile(logfile, "\<thead\>\<th class=\"col-md-3\"\>Lines of Code\</th\>\<th class=\"col-md-3\"\>Blank Lines\</th\>\<th class=\"col-md-3\"\>Comments\</th\>\<th class=\"col-md-3\"\>Total\</th\>\</thead\>\<tbody\>");	
	real total = toReal(totalComments +totalBlankLines +totalLinesOfCode);
	
	appendToFile(logfile, "\<tr\>");
	appendToFile(logfile, "\<td style=\"\"\><totalLinesOfCode>\</td\>");
	appendToFile(logfile, "\<td\><totalBlankLines>\</td\>");
	appendToFile(logfile, "\<td\><totalComments>\</td\>");
	appendToFile(logfile, "\<td\><total>\</td\>");
	appendToFile(logfile, "\</tr\>");
	
	appendToFile(logfile, "\<tr\>");
	appendToFile(logfile, "\<td style=\"\"\><(totalLinesOfCode / total) * 100.0>%\</td\>");
	appendToFile(logfile, "\<td\><(toReal(totalBlankLines) / toReal(total)) *100.0>%\</td\>");
	appendToFile(logfile, "\<td\><(totalComments / total) * 100.0>%\</td\>");
	appendToFile(logfile, "\<td\>100%\</td\>");
	appendToFile(logfile, "\</tr\>");
	
	appendToFile(logfile, "\</tbody\>\</table\>");	
	
	appendToFile(logfile, "The Lines of Code for this project was rated: \<strong\><printVerdict(calcLOCScore(totalLinesOfCode))>\</strong\>\</br\>");

	// graphs
	appendToFile(logfile, "\<div id=\"<printProjectID(project)>loc\" class=\"nvd3chart\"\>\<svg\>\</svg\>\</div\>");
	appendToFile(logfile, "\<script\>projects.<printProjectID(project)>.loc = [{\"label\": \"Blank\", \"value\": <totalBlankLines>}, {\"label\": \"Comments\", \"value\": <totalComments>}, {\"label\": \"Lines of Code\", \"value\": <totalLinesOfCode>}] \</script\>");
}

public void printUnitSize(tuple [int, rel[str, int, int]] unitsizes, loc logfile) {
	appendToFile(logfile, "\<h2\>Unit Size per method\</h2\>");
	
	//appendToFile(logfile, "\<button id=\"showUC\"\>Show\</button\>");
	appendToFile(logfile, "\<table id=\"uc\" style=\"width: 1200px;word-wrap: break-word;table-layout:fixed;\" class=\"table hidden table-striped table-bordered\" \>\<thead\>\<th class=\"col-md-6\"\>Method Name\</th\>\<th class=\"col-md-3\"\>LOC\</th\>\<th class=\"col-md-3\"\>Judgement\</th\>\</thead\>\<tbody\>");	
	for (unit <- unitsizes[1]) {
		// omit small unit sizes
		if (size(unitsizes[1]) <= 20) {
			appendToFile(logfile, "\<tr\>");
			appendToFile(logfile, "\<td style=\"\"\><unit[0]>\</td\>");
			appendToFile(logfile, "\<td\><unit[1]>\</td\>");
			appendToFile(logfile, "\<td\><unit[2]>\</td\>");
			appendToFile(logfile, "\</tr\>");
		} else if (unit[1] > 20) { 
			appendToFile(logfile, "\<tr\>");
			appendToFile(logfile, "\<td style=\"\"\><unit[0]>\</td\>");
			appendToFile(logfile, "\<td\><unit[1]>\</td\>");
			appendToFile(logfile, "\<td\><unit[2]>\</td\>");
			appendToFile(logfile, "\</tr\>");			
		}
	}
	if (size(unitsizes[1]) > 20) {
		appendToFile(logfile, "Results lower than 20 LOC ommitted");
		
	}
	appendToFile(logfile, "\</tbody\>\</table\>");	
	
	
	appendToFile(logfile, "\<h2\>Unit Size for project\</h2\>");
	
	appendToFile(logfile, "The unit size for this project was rated \<strong\><printVerdict(unitsizes[0])>\</strong\>\</br\>");
	
}

public void printComplexity(tuple[int, lrel[loc, int, int], tuple[real, real, real, real]] cc, loc logfile, loc project) {
	appendToFile(logfile, "\<h2\>Cyclomatic Complexity\</h2\>");
	//appendToFile(logfile, "\<button \>Show\</button\>");
	
	appendToFile(logfile, "\<table id=\"cc\" style=\"width: 1200px;word-wrap: break-word;table-layout:fixed;\" class=\"table hidden table-striped table-bordered\"\>\<thead\>\<th class=\"col-lg-6\"\>Method Name\</th\>\<th class=\"col-lg-3\"\>LOC\</th \>\<th class=\"col-lg-3\"\>Complexity(CC)\</th\>\</thead\>\<tbody\>");
	for (method <- cc[1]) {
		if (size(cc[1]) < 20) {
			appendToFile(logfile, "\<tr\>");
			appendToFile(logfile, "\<td\><method[0]>\</td\>");
			appendToFile(logfile, "\<td\><method[1]>\</td\>");
			appendToFile(logfile, "\<td\><method[2]>\</td\>");
			appendToFile(logfile, "\</tr\>");
		} else if (method[2] >= 5) {
			appendToFile(logfile, "\<tr\>");
			appendToFile(logfile, "\<td\><method[0]>\</td\>");
			appendToFile(logfile, "\<td\><method[1]>\</td\>");
			appendToFile(logfile, "\<td\><method[2]>\</td\>");
			appendToFile(logfile, "\</tr\>");
		}
	}
	if (size(cc[1]) > 20) {
		appendToFile(logfile, "Results lower than 5 CC ommitted");
	}
	appendToFile(logfile, "\</tbody\>\</table\>\</br\>");
	
	
	appendToFile(logfile, "\<table style=\"width: 1200px;word-wrap: break-word;table-layout:fixed;\" class=\"table table-striped table-bordered\" \>");
	appendToFile(logfile, "\<thead\>\<th class=\"col-md-3\"\>Low\</th\>\<th class=\"col-md-3\"\>Moderate\</th\>\<th class=\"col-md-3\"\>High\</th\>\<th class=\"col-md-3\"\>Very High\</th\>\</thead\>\<tbody\>");		
	appendToFile(logfile, "\<tr\>");
	appendToFile(logfile, "\<td style=\"\"\><cc[2][0]>%\</td\>");
	appendToFile(logfile, "\<td\><cc[2][1]>%\</td\>");
	appendToFile(logfile, "\<td\><cc[2][2]>%\</td\>");
	appendToFile(logfile, "\<td\><cc[2][3]>%\</td\>");
	appendToFile(logfile, "\</tr\>");
	
	appendToFile(logfile, "\</tbody\>\</table\>");	
	
	appendToFile(logfile, "The cyclomatic complexity for this project was rated: \<strong\><printVerdict(cc[0])>\</strong\>\</br\>");
	
	
	// graphs
	appendToFile(logfile, "\<div id=\"<printProjectID(project)>cc\"\>\<svg\>\</svg\>\</div\>");
	appendToFile(logfile, "\<script\>projects.<printProjectID(project)>.cc = [{\"label\": \"Trivial\", \"value\": <cc[2][0]>}, {\"label\": \"Moderate\", \"value\": <cc[2][1]>}, {\"label\": \"High\", \"value\": <cc[2][2]>}, {\"label\": \"Very High\", \"value\": <cc[2][3]>}] \</script\>");	
	
}
  
public str printProjectID(loc project){
	return replaceAll(project.authority, ".","_");
}

public void printDuplication(tuple [real, int] duplicates, loc logfile) {
	block = "blocks";
	verb = "were";
	if (duplicates[1] == 1) {
		blocks = "block";
		verb = "was";
	}
	appendToFile(logfile, "\<h2\>Clone Detection\</h2\>");
	appendToFile(logfile, "There <verb> <duplicates[1]> duplicate <block> of code found in this project.\</br\>");
	appendToFile(logfile, "The duplication percentage for this project is: <duplicates[0]>%\</br\>");
	appendToFile(logfile, "The duplication score for this project was rated: \<strong\><printVerdict(calcDuplicationScore(duplicates[0]))>\</strong\>\</br\>");

}

public void printExecutionTime(Duration duration, loc logfile) {
	newline = "\</br\>";
	durationStr = "Total calculations completed in: <duration.years> years, <duration.months> months, <duration.days> days, <duration.hours> hours, <duration.minutes> minutes, <duration.seconds> seconds and <duration.milliseconds> milliseconds.";
	iprintln(durationStr);
	durationStr += newline;
	appendToFile(logfile, durationStr);
}

public void printProjectExecutionTime(Duration duration, loc logfile) {
	newline = "\</br\>";
	durationStr = "Calculations for project completed in: <duration.years> years, <duration.months> months, <duration.days> days, <duration.hours> hours, <duration.minutes> minutes, <duration.seconds> seconds and <duration.milliseconds> milliseconds.";
	iprintln(durationStr);
	durationStr += newline;
	appendToFile(logfile, durationStr);
}

public void printMetricCalculationTime(Duration duration, str metric, loc logfile) {
	newline = "\</br\>";
	durationStr = "Calculations for <metric> were completed in: <duration.years> years, <duration.months> months, <duration.days> days, <duration.hours> hours, <duration.minutes> minutes, <duration.seconds> seconds and <duration.milliseconds> milliseconds.";
	iprintln(durationStr);
	durationStr += newline;
	appendToFile(logfile, durationStr);
}

public void printTestCoverage(tcscore, loc logfile) {
	appendToFile(logfile, "\<h2\>Test Coverage\</h2\>");
	appendToFile(logfile, "Test coverage for this project was rated: \<strong\><printVerdict(tcscore)>\</strong\>\</br\>");
	
}
public void printMaintainability(int analysability, int changeability, int stability, int testability, loc logfile) {
	appendToFile(logfile, "\<h2\>Maintainability\</h2\>");
	appendToFile(logfile, "\<table style=\"width: 1200px;word-wrap: break-word;table-layout:fixed;\" class=\"table table-striped table-bordered\"\>\<thead\>\<th class=\"col-lg-6\"\>Method Name\</th\>\<th class=\"col-lg-3\"\>LOC\</th \>\</thead\>\<tbody\>");

	appendToFile(logfile, "\<tr\>");
	appendToFile(logfile, "\<td\>Analyseability\</td\>");
	appendToFile(logfile, "\<td\><printVerdict(analysability)>\</td\>");
	appendToFile(logfile, "\</tr\>");
	
	appendToFile(logfile, "\<tr\>");
	appendToFile(logfile, "\<td\>Changeability\</td\>");
	appendToFile(logfile, "\<td\><printVerdict(changeability)>\</td\>");
	appendToFile(logfile, "\</tr\>");
	
	appendToFile(logfile, "\<tr\>");
	appendToFile(logfile, "\<td\>Stability\</td\>");
	appendToFile(logfile, "\<td\><printVerdict(stability)>\</td\>");
	appendToFile(logfile, "\</tr\>");
	
	appendToFile(logfile, "\<tr\>");
	appendToFile(logfile, "\<td\>Testability\</td\>");
	appendToFile(logfile, "\<td\><printVerdict(testability)>\</td\>");
	appendToFile(logfile, "\</tr\>");
	
	appendToFile(logfile, "\<tr\>");
	appendToFile(logfile, "\<td\>Overall Maintainability\</td\>");
	appendToFile(logfile, "\<td\><printVerdict(toInt(median([analysability, changeability, stability, testability])))>\</td\>");
	appendToFile(logfile, "\</tr\>");

	appendToFile(logfile, "\</tbody\>\</table\>\</br\>");

}
public void printEndProject(loc logfile, loc project) {
	//appendToFile(logfile, "\<script\>delete projects.<printProjectID(project)>\</script\>");
	appendToFile(logfile, "\<script \> $(\"#showUC\").on(\"click\", function(){ $(\"#cc\").toggleClass(\"hidden\");}\</script\>");
	appendToFile(logfile, "\<script \> $(\"#showCC\").on(\"click\", function(){ $(\"#cc\").toggleClass(\"hidden\");}\</script\>");
}

