module Test

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import IO;
import Prelude;

public int calcLoc(loc fileLocation)
{
	int n = 0;
	
	for(line <- readFileLines(fileLocation))
		if(trim(line) != "" && !startsWith(trim(line),"/") && !startsWith(trim(line),"*")) 
			n += 1;
	return n;	
}

public value calcClassLoc(loc location){
	 int n = 0;
	 model = createM3FromEclipseProject(location);
	 for(c <-classes(model)) n += calcLoc(c);
	 return n;
}