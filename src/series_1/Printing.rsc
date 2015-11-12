module series_1::Printing

import Prelude;
import series_1::Duplication;
import series_1::LOC;
import series_1::Scoring;
import series_1::Util;

public loc startReport() {
	loc logfile = |project://Software-Evolution/reports/report.html|;
	println("writing report");
	// write or overrwrite file. 
	str msg  = "\<html\>\<header\>";
	writeFile(logfile, msg);	
	appendToFile(logfile, "\<link href=\"css/bootstrap.min.css\" rel=\"stylesheet\"\>");
	appendToFile(logfile, "\</header\>\<body\>");
	appendToFile(logfile, "\<script src=\"js/bootstrap.min.js\"\>\</script\>");
	appendToFile(logfile, "\<div class=\"container\"\>");
	appendToFile(logfile, "\<div class=\"row\"\>");

	return logfile;	
	
}

public void endReport(loc file) {
	appendToFile(file, "\</div\>");
	appendToFile(file, "\</body\>\n\</html\>");
}


public void printLOC(map[loc, tuple[int,int,int]] containmentLocs, loc logfile) {
	// aggregate results
	totalLinesOfCode = ((0 | it + (containmentLocs[c])[0] | c <- containmentLocs));
	totalBlankLines = ((0 | it + (containmentLocs[c])[1] | c <- containmentLocs));
	totalComments = ((0 | it + (containmentLocs[c])[2] | c <-containmentLocs));
	
	appendToFile(logfile, "\<h2\>Lines of code\</h2\>");
	appendToFile(logfile, "Total LOC: <totalLinesOfCode>\</br\>");
	appendToFile(logfile, "Total Blank lines: <totalBlankLines>\</br\>");
	appendToFile(logfile, "Total Comments: <totalComments>\</br\>");
	appendToFile(logfile, "The Lines of Code for this project was rated \<strong\><printVerdict(calcLOCScore(totalLinesOfCode))>\</strong\>\</br\>");
	
}

public void printUnitSize(tuple [str, rel[str, int, int]] unitsizes, loc logfile) {
	appendToFile(logfile, "\<h2\>Unit Size per method\</h2\>");
	
	//appendToFile(logfile, "\<div class=\".table-responsive\"\>");
	appendToFile(logfile, "\<table style=\"width: 1200px;word-wrap: break-word;table-layout:fixed;\" class=\"table table-striped table-bordered\" \>\<thead\>\<th class=\"col-md-6\"\>Method Name\</th\>\<th class=\"col-md-3\"\>LOC\</th\>\<th class=\"col-md-3\"\>Judgement\</th\>\</thead\>\<tbody\>");	
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
	//appendToFile(logfile, "\</div\>");
	
	appendToFile(logfile, "\<h2\>Unit Size for project\</h2\>");
	
	appendToFile(logfile, "The unit size for this project was rated \<strong\><unitsizes[0]>\</strong\>\</br\>");
	
}

public void printComplexity(tuple[int,lrel[str,int,int]] cc, loc logfile) {
	appendToFile(logfile, "\<h2\>Cyclomatic Complexity\</h2\>");
	appendToFile(logfile, "\<table style=\"width: 1200px;word-wrap: break-word;table-layout:fixed;\" class=\"table table-striped table-bordered\"\>\<thead\>\<th class=\"col-lg-6\"\>Method Name\</th\>\<th class=\"col-lg-3\"\>LOC\</th \>\<th class=\"col-lg-3\"\>Complexity(CC)\</th\>\</thead\>\<tbody\>");
	
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
	appendToFile(logfile, "The duplication score for this project is: <printVerdict(calcDuplicationScore(duplicates[0]))>\</br\>");

}

public void printExecutionTime(Duration duration, loc logfile) {
	durationStr = "Calculations completed in: <duration.years> years, <duration.months> months, <duration.days> days, <duration.hours> hours, <duration.minutes> minutes, <duration.seconds> seconds and <duration.milliseconds> milliseconds.\</br\>";
	iprintln(durationStr);
	appendToFile(logfile, durationStr);
}

public void printMetricCalculationTime(Duration duration, str metric, loc logfile) {
	durationStr = "Calculations for <metric> were completed in: <duration.years> years, <duration.months> months, <duration.days> days, <duration.hours> hours, <duration.minutes> minutes, <duration.seconds> seconds and <duration.milliseconds> milliseconds.\</br\>";
	iprintln(durationStr);
	appendToFile(logfile, durationStr);
}