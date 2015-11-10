module series_1::Duplication

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import series_1::LOC;
import IO;
import Prelude;

public int getDuplicates(M3 model, rel [str, int, int] unitsizes, bool debug, int totalLOC) {

	list[list[str]] duplicateLines = [];

	list[list[str]] duplicateLineSets = [];

	int duplicates = 0;

	for (class <- classes(model)) {

	if (getLOC(class, debug)[0] < 6) continue;
		
		list[str] srcLines = [];

		for (line <- readFileLines(class)) srcLines += trim(line);
		
		int begin = 0;
		int end = 5;

		while (end < size(srcLines)){
			list[str] slice = srcLines[begin..end];

			if (slice in duplicateLines) {

				duplicates += 1;
				duplicateLineSets = push(slice, duplicateLineSets);

				if(end+6 > size(srcLines) -1) break;
				else end +=6;	
				
			} else {

				duplicateLines = push(slice, duplicateLines);
				begin += 1;
				end += 1;

			}
		}
	}

	if(debug){
		iprintln(duplicateLineSets);
		println("duplicates <duplicates>");
	}

	real percentageDuplicates = duplicates *6.0 /totalLOC * 100.0;
	iprintln("Percentage of duplications: <percentageDuplicates>%");
	
	return duplicates;
}