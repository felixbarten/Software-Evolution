module series_1::Series_1

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Prelude;

public void createModel() {
	myModel = createM3FromEclipseProject(|project://smallsql0.21_src|);
	
	myMethods = methods(myModel);
	myMethodList = toList(myMethods);
	println(myMethodList[0]);
	myAST = getMethodASTEclipse(myMethodList[0], model=myModel);
	
	methodSrc = readFile(myMethodList[0]);
	println(methodSrc);
	
	myStatements = (0 | it + 1 | /Statement _ := myAST);
	println(myStatements);
	
	
		//myModel2 = createM3FromEclipseProject(|project://hsqldb-2.3.1|);
	
}