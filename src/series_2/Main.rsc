module series_2::Main

import Prelude;
import DateTime;

import series_2::Printing;
import series_2::ASTCloneDetection;
import series_2::misc::util;
import series_2::misc::datatypes;

void main(loc project){
	datetime beginTime = now();

	clonePairs = getClonePairs(project); 
	cloneClasses = getCloneClasses(({}| it+<l.location,r.location> | < snip l, snip r> <- clonePairs));
	println("\nTotal clone pairs found: <size(clonePairs)>");	
	println("Total clone classes found: <size(cloneClasses)>\n");	
	Duration execution = createDuration(beginTime, now());
	
	writeOutputToFile(clonePairs, cloneClasses, execution,project);

}

void writeOutputToFile(clonePairs, cloneClasses, execution, project){

	loc report = startReport(project);

	printSnipsToFile(clonePairs, report);
	printBarGraph(clonePairs, report, project);
	printBarGraph2(clonePairs, report, project);
	printChordDiagram(clonePairs, report, project);
	printForceGraph(clonePairs, report, project);
	printProjectExecutionTime(execution, report); 	
	
	printClassesBarGraph(cloneClasses, report, project);
	printClassesLOCBarGraph(cloneClasses, report, project);

	printClonePairs(clonePairs, report, project);
	printCloneClasses(cloneClasses, report, project);

	
	endReport(report);
}