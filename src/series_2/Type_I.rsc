module series_2::Type_I

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import Prelude;
import series_1::LOC;

public rel [loc, loc] getDuplicates(M3 model, rel [str, int, int] unitsizes, bool debug) {

	list[list[str]] duplicateLines = [];

	list[tuple[loc, list[str]]] duplicateLineSets = [];

	rel[loc, loc] duplications;
	int duplicates = 0;
	int classesSize = size(classes(model));
	int divider = round(classesSize / 20.0);
	int counter = 0;
	real percentage = 0.0;
	if (divider == 0) {
		divider = 1; 
	}

	for (class <- classes(model)) {
		if (counter % divider == 0) {
			if (counter == 0) 
				percentage = 0.0;
			else 
				percentage = (toReal(counter) / toReal(classesSize)) * 100.0;
			println("Duplication calculation progress: <round(percentage,0.1)>%");
		} 
		counter += 1;
		if (counter == classesSize) 
			println("Duplication calculations on: 100.0%");
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
				
				duplications += {<slice,slice>};

				if(end+1 > size(srcLines) -1) break;
				else end +=1;	
				
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
		
	return duplications;
}

public rel [loc, loc] getDuplicates2(M3 model, bool debug) {

	list[list[str]] duplicateLines = [];

	list[tuple[loc, list[str]]] duplicateLineSets = [];
	containmentLocs = ();

	rel[loc, loc] duplications;
	int duplicates = 0;
	int classesSize = size(classes(model));
	int divider = round(classesSize / 20.0);
	int counter = 0;
	real percentage = 0.0;
	if (divider == 0) {
		divider = 1; 
	}
	list[loc] parsed = [];

	for (class <- classes(model)) {
		list[loc] units = [c | c <- invert(model@containment)[class], c.scheme == "java+compilationUnit"];
		for (loc unit <- units){
			if (debug) 
				iprintln("Parsing: <unit>");
			if (unit notin parsed) {
				containmentLocs += (unit: getDuplication(unit, debug));
				parsed += unit;
			}
		}
	
		if (counter % divider == 0) {
			if (counter == 0) 
				percentage = 0.0;
			else 
				percentage = (toReal(counter) / toReal(classesSize)) * 100.0;
			println("Duplication calculation progress: <round(percentage,0.1)>%");
		} 
		counter += 1;
		if (counter == classesSize) 
			println("Duplication calculations on: 100.0%");
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
				
				duplications += {<slice,slice>};

				if(end+1 > size(srcLines) -1) break;
				else end +=1;	
				
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
		
	return containmentLocs;
}

public list[str] getDuplication(loc unit, bool debug) {
	int beginline =0 ;
	int begincolumn = 0;
	int endLine = 6;
	int endColumn = 0;
	int offset = 0;
	int length = 6; 
	loc newloc = unit + "(<offset>, <length>, \<0,0\>,\< 0,0\>)";
	unit = unit[offset = offset];
	unit = unit[begin = <beginline, begincolumn>];
	unit = unit[end = <endLine, endColumn>];
	
	list[str] lines = readFileLines(unit);
	
	iprintln(lines);
	
	return lines;
}
/*
	Uses the following table to determine score:
	0% - 3%
	3% - 5%
	5% - 10%
	10% - 20%
	20% - 100%
*/
public int calcDuplicationScore(real dPer){

	int result = 1;

	if(dPer <= 3.0){
		result = 5;	
	} else if(dPer > 3.0 && dPer <= 5.0){
		result = 4;	
	} else if(dPer > 5.0 && dPer <= 10.0){
		result = 3;	
	} else if(dPer > 10.0 && dPer <= 20.0){
		result = 2;	
	} else if(dPer > 20.0 && dPer <= 100.0){
		result = 1;	
	}

	return result;
}