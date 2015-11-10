module series_1::TestCoverage

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import Prelude;
import series_1::Util;
import series_1::LOC;

public real calcTest(int totalLoc){
	model = createM3FromEclipseProject(|project://smallsql0.21_src/|);
	ext = { createAstFromFile(c, false) | c <- classes(model)};
	testClassNames = {};	
	for(c <- ext){
		visit(c){
			case "class"(n,_,_,_) : if(isTest(n)) {
				testClassNames += c;
			}	
		}
	}

	calls = {};	

	for(c <- testClassNames){
		calls += getMethodCalls(c);
	}

	allMethods = {<methodName(m.path),m> | m <- methods(model)};

	while(calls != tr(allMethods,model, calls)){
		calls += tr(allMethods,model, calls);
	}
	
	tmp = { r | <e,r> <- allMethods, e in calls}; 

	testLoc = (0 | it + getLOC(e,false)[0] * 1.0 | loc e <- tmp);
	real coverage = testLoc/totalLoc * 100.0;
	
	return coverage;
}

private set[str] tr(allMethods,model,calls){
	result = calls;
	tmp = { r | <e,r> <- allMethods, e in result}; 
	calledMethods = {getMethodASTEclipse(i, model=model)| i <- tmp};
	iprintln(size(result));
	for(t <- calledMethods){
		result += getMethodCalls(t);	
	}	
	iprintln(size(result));
	return result;
}

private set[str] getMethodCalls(ast){

	set[str] calls = {};	

	visit(ast){
		case \methodCall(_,n,_):{
			 calls += n;
		 }	
		case \methodCall(_,_,n,_):{
			 calls += n;	
		}
	}		

	return calls;
}

private bool isTest(str s){
	return /.*Test.*/ := s;
}