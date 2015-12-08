module series_2::Printing

import Prelude;
import analysis::statistics::Descriptive;
import util::Math;

alias snip = tuple[ loc location, value code];

public loc startReport(loc project) {
	loc file = |project://Software-Evolution/reports/clonereport.html|;
	println("writing report");
	// write or overrwrite file. 
	str msg  = "\<html\>\<header\>";
	writeFile(file, msg);	
	appendToFile(file, "\<link href=\"css/bootstrap.min.css\" rel=\"stylesheet\"\>");
	appendToFile(file, "\<link href=\"css/custom.css\" rel=\"stylesheet\"\>");
	
	appendToFile(file, "\</header\>\<body\>");
	appendToFile(file, "\<script src=\"js/bootstrap.min.js\"\>\</script\>");
	appendToFile(file, "\<script src=\"js/d3.min.js\"\>\</script\>");
	appendToFile(file, "\<script src=\"js/nvd3.min.js\"\>\</script\>");
	appendToFile(file, "\<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js\"\>\</script\>");
	appendToFile(file, "\<script\>var projects = {");

	str projectname = project.authority;
	projectname = replaceAll(projectname, ".", "_");
	appendToFile(file, "\"<projectname>\": {\"cc\": [], \"cc1\": [], \"loc\": []}");

	appendToFile(file, "};\</script\> ");
	appendToFile(file, "\<div class=\"container\"\>");
	appendToFile(file, "\<div class=\"row\"\>");

	return file;	
}

public void endReport(loc file) {
	appendToFile(file, "\<script src=\"js/clonegraphs.js\"\>\</script\>");

	appendToFile(file, "\</div\>");
	appendToFile(file, "\</body\>\n\</html\>");
	println("Finished writing report");
}

public void printExecutionTime(Duration duration, loc file) {
	newline = "\</br\>";
	durationStr = "Total calculations completed in: <duration.years> years, <duration.months> months, <duration.days> days, <duration.hours> hours, <duration.minutes> minutes, <duration.seconds> seconds and <duration.milliseconds> milliseconds.";
	iprintln(durationStr);
	durationStr += newline;
	appendToFile(file, durationStr);
}

public void printProjectExecutionTime(Duration duration, loc file) {
	newline = "\</br\>";
	durationStr = "Calculations for project completed in: <duration.years> years, <duration.months> months, <duration.days> days, <duration.hours> hours, <duration.minutes> minutes, <duration.seconds> seconds and <duration.milliseconds> milliseconds.";
	iprintln(durationStr);
	durationStr += newline;
	appendToFile(file, durationStr);
}

public void printMetricCalculationTime(Duration duration, str metric, loc file) {
	newline = "\</br\>";
	durationStr = "Calculations for <metric> were completed in: <duration.years> years, <duration.months> months, <duration.days> days, <duration.hours> hours, <duration.minutes> minutes, <duration.seconds> seconds and <duration.milliseconds> milliseconds.";
	iprintln(durationStr);
	durationStr += newline;
	appendToFile(file, durationStr);
}

public void printSnipsToFile (rel[snip, snip] clones, loc file){
	int counter = 1; 
	for (tuple[snip, snip] clone <- clones) {
		appendToFile(file, "Clone pair: <counter>\</br\>");	
		appendToFile(file, "<clone[0].location>\</br\>");
		appendToFile(file, "<clone[1].location>\</br\>");
		appendToFile(file, "\</br\>");
		counter += 1;
	}
}

public void printTypeIClones(rel[snip, snip] clonepairs, loc file) {
}

public void printMatrixGraph(rel[snip, snip] clonepairs) {
	loc JSON = |project://Software-Evolution/reports/json/matrix.json|;
}

public void printBarGraph(rel[snip, snip] clonepairs, loc file) {

	// PRINT JSON DATA FILE
	loc JSON = |project://Software-Evolution/reports/json/bargraph.js|;
	startJSON(JSON);
	// insert key and values
	appendToFile(JSON, "\t\"key\": \"Code clones size\",\n");
	
	appendToFile(JSON, "\t\"values\": [\n ");
	
	values = "";
	// sort data 
	for (tuple[snip first, snip second] pair <- clonepairs){
		values += "\t{\n";
		values += "\t\t\"label\": \"<pair.first.location.path><pair.first.location.begin.line><pair.first.location.end.line> + <pair.second.location.path><pair.second.location.begin.line><pair.second.location.end.line>\",\n";
		lines =  pair.first.location.end.line - pair.first.location.begin.line;
		values += "\t\t\"value\": <lines>\n";
		values += "\t},\n";
	}
	// delete trailing ,
	values = values[..-1];
	
	// write values 
	appendToFile(JSON, values);
	appendToFile(JSON, "]");
	// end json file
	endJSON(JSON);
}
public void startJSON(loc file) {
	writeFile(file, "");
	appendToFile(file, "bardata = [\n");
	appendToFile(file, "\t{\n");
}
public void startDataSet(loc file) {

}
public void endJSON(loc file) {
	appendToFile(file, "}\n];");
}
