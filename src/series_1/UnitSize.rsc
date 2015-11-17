module series_1::UnitSize

import IO;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import series_1::LOC;
import series_1::Scoring;
import util::Math;

public tuple [int, rel[str, int, int]] getUnitsSize(M3 project, int totalLOC, bool debug) {
	rel[str, int, int] unitSizes = {};
	int moderate = 0;
	int high = 0;
	int simple = 0;
	int vhigh = 0;

	for (method <- methods(project)) {
		LOC = getLOC(method, false)[0];
		category = getMethodLOCCategory(LOC); 
		unit = {<method.path, LOC, category>};
		unitSizes += unit;
		switch(category){
			case 2:
				vhigh += LOC;
			case 3:
				high += LOC;
			case 4:
				moderate += LOC;
			case 5:
				simple += LOC;			
		}
	}
	real percentageModerate = toReal(toReal(moderate)/totalLOC*100.0);
	real percentageHigh = toReal((toReal(high)/totalLOC)*100.0);
	real percentageVeryHigh = toReal(toReal(vhigh)/totalLOC*100.0);
	real percentageSimple = toReal(toReal(simple)/totalLOC*100.0);
	println(percentageHigh);
	
	int unitSizeCategory = 1;
	
	if (percentageModerate <= 25 && percentageHigh == 0 && percentageVeryHigh == 0) {
		unitSizeCategory = 5;
	} else if (percentageModerate > 25 && percentageModerate <= 30 && percentageHigh <= 5 && percentageVeryHigh == 0) {
		unitSizeCategory = 4;
	} else if (percentageModerate > 30 && percentageModerate <= 40 && percentageHigh <= 10 && percentageVeryHigh == 0) {
		unitSizeCategory = 3;
	} else if (percentageModerate > 40 && percentageModerate <= 50 && percentageHigh <= 15 && percentageVeryHigh <= 5) {
		unitSizeCategory = 2;
	} else if (percentageModerate > 50 || percentageHigh > 15 || percentageVeryHigh > 5){
		unitSizeCategory = 1;
	}
	if(debug){
		prettyPrintUnitSize(unitSizes); 
    }	
	return <unitSizeCategory, unitSizes>;
}


public int getMethodLOCCategory(LOC) {
	if (LOC >= 0 && LOC <= 20) {
		return 5;
	} else if (LOC > 20 && LOC <= 50) {
		return 4;
	} else if (LOC > 50 && LOC <= 100) {
		return 3;
	} else if (LOC > 100) {
		return 2;
	} else {
		// should never reach this
		return 1;
	}
}
public void prettyPrintUnitSize(rel[str, int, int] unitsizes) {
	iprintln ("Unit Sizes:");
	for (unit <- unitsizes) {
		iprintln("Method: <unit[0]> LOC: <unit[1]> Judgement: <printVerdict(unit[2])>");
	}
}