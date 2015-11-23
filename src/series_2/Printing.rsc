module series_2::Printing

import Prelude;
import analysis::statistics::Descriptive;
import util::Math;

public loc startReport(list[loc] projects) {
	loc logfile = |project://Software-Evolution/reports/duplicationReport.html|;
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
