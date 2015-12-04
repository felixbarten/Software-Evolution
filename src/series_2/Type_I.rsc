module series_2::Type_I

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import Prelude;

alias Snip = tuple[loc location, list[str] lines];
alias Snips = lrel[loc, list[str]]; 


public value getCloneClasses(rel[value, value] a){
	a += ident(carrier(a)); 
	res = groupRangeByDomain(a);

	return for ( c<- res) if(size(c) > 1) append c;	
}

public tuple[ real, int] getDuplicates(loc project, bool debug, int totalLOC) {
	 
	model = createM3FromEclipseProject(project);
	int gap = 6;

	Snips duplicateLines = [];

	list[list[str]] duplicateLineSets = [];
	rel[Snip, Snip] clonePairs = {};

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
				percentage = 4.0;
			else 
				percentage = (toReal(counter) / toReal(classesSize)) * 100.0;
			println("Duplication calculation progress: <round(percentage,0.1)>%");
		} 
		counter += 1;
		if (counter == classesSize) 
			println("Duplication calculations on: 100.0%");
		
		list[str] srcLines = [];
		fileLines = readFileLines(class);

		if ( size(fileLines) < 6) continue;
		for (line <- fileLines) srcLines += trim(line);
		
		int begin = 0;
		int end = begin+gap;

		while (end < size(srcLines)){
			
			loc f = class;	
			f = f[offset = 0];
			f = f[length = 6];
			f = f[begin = < begin, 0>];
			f = f[end = < end+1, 0>];
			list [str] slice = srcLines[begin..end];
			
			Snip p = <f,slice>;
			bool exists = false;

		    for(s <- duplicateLines){
		     if(slice := s[1]){
		     	exists = true;
				duplicates += 1;
				duplicateLineSets = push(slice, duplicateLineSets);
				clonePairs += <s,p>; 
				begin +=1;
				if(end+1 > size(srcLines) -1) break;
				else end +=1;	
		     }
		    }
				
			 if(!exists) {
				duplicateLines += p;
				begin += 1;
				end = begin+gap;
			}
		}
	}
	cloneClasses = getCloneClasses(clonePairs);
	if(debug){
		//iprintln(duplicateLineSets);
	//	println("duplicates <duplicates>");
		//iprintln(getOneFrom(clonePairs));
		iprintln(cloneClasses);

	}
	
	real percentageDuplicates = duplicates *6.0 /totalLOC * 100.0;
		
	return <percentageDuplicates,duplicates>;
}