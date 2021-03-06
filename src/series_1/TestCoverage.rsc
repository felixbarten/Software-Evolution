module series_1::TestCoverage

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Prelude;
import series_1::Util;
import series_1::LOC;
import util::Math;


public real calcTestCoverage(M3 model,int totalLoc){
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

	while(calls != findCalledMethodNames(allMethods, model, calls)){
		calls += findCalledMethodNames(allMethods, model, calls);
	}
	
	tmp = { r | <e,r> <- allMethods, r in calls}; 
	testLoc = (0 | it + getLOC(e,false)[0] * 1.0 | loc e <- tmp);
	real coverage = testLoc/totalLoc * 100.0;
	
	return round(coverage,0.1);
}

private set[loc] findCalledMethodNames(allMethods,model,calls){
	result = calls;
	tmp = { r | <e,r> <- allMethods}; 
	calledMethods = {getMethodASTEclipse(i, model=model)| i <- tmp};
	for(t <- calledMethods){
		result += getMethodCalls(t);	
	}	
	return result;
}

private set[loc] getMethodCalls(ast){

	set[loc] calls = {};	
	visit(ast){
		case a:\methodCall(_,n,_):{
			try calls += a@decl;
			catch:;
		 }
		case b:\methodCall(_,_,n,_):{
			try calls += b@decl;
			catch:;	
		}
	}		

	return calls;
}

private bool isTest(str s){
	return /.*Test.*/ := s;
}

/*
	Thresholds for testcoverage
	>95
	80-95
	60-80
	20-60
	<20
*/
public int calcTestCoverageScore(real r){

	int result = 1;

	if(r > 95.0){
		result = 5;	
	} else if(r > 80.0 && r <= 95.0){
		result = 4;	
	} else if(r > 60.0 && r <= 80.0){
		result = 3;	
	} else if(r > 20.0 && r <= 60.0){
		result = 2;	
	} else if(r <= 20.0){
		result = 1;	
	} else {//Something went wrong
		result = -1;	
	}

	return result;
}