module series_1::MComplexity

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Prelude;
import series_1::LOC;

public int calcMethodCC(methodAST){

	int i = 1;

	visit(methodAST){
		case "if"(_, _) : i +=1;
		case "if"(_, _,_) : i += 1;
		case "conditional"(_, _,_) : i +=1;
		case "while"(_, _) : i += 1;
		case "for"(_, _, _) : i += 1;
		case "for"(_, _, _, _) : i +=1;
		case "foreach"(_, _, _) : i +=1;
		case "case"(_) : i += 1;
		case "infix"(_,"&&",_) : i += 1;
		case "infix"(_,"||",_) : i += 1;
		case "catch"(_, _): i += 1;
	}

	return i;
} 

test bool t1(){
	myModel = createM3FromEclipseProject(|project://testJava/|);
	totalLoc = 47;
	result = calcCCScore(47, myModel); 	
	return result[0] == 5;
}

public list[tuple[loc,int,int]] calcProjectCC(M3 input){
	model = input;
	int counter = 0;
	int methodSize = size(methods(model)); 
	
	return for(m <- methods(model)){
	 	if (counter % 100 == 0) {
	 		println("Calculated complexity for <counter> out of <methodSize> methods");
	 	}
	 	counter += 1;
	 	methodAST = getMethodASTEclipse(m,model=model);
	 	append <m, getLOC(m, false)[0], calcMethodCC(methodAST)>;
	 }
}

/*
	Uses the following thresholds to determine score(descending):
		<M ,H ,V>
		---------
		<50,15,5>
		<40,10,0>
		<30, 5,0>
		<25, 0,0>
*/
public tuple [ int, lrel[ loc, int, int], tuple[int,int,int,int] ] calcCCScore( M3 model,totalLoc){

	int low = 0;
	int moderate = 0;
	int high = 0;
	int veryHigh = 0;	
	int result = 0;

	methodCCs = calcProjectCC(model);

	for ( item <- methodCCs ){
		mloc = item[1];
		cc = item[2];

		if( cc <= 10 ){
			low = low + mloc;
		}	
		if( cc >= 11 && cc <= 20 ){
			moderate = moderate + mloc;
		}	
		if( cc >= 21 && cc <= 50 ){
			high = high + mloc;
		}	
		if( cc > 50 ){
			veryHigh = veryHigh + mloc;
		}	
	}
	//println(low);
	//println(moderate);
	//println(high);
	//println(veryHigh);

	int pL = moderate/totalLoc*100;
	int pM = moderate/totalLoc*100;
	int pH = high/totalLoc*100;
	int pV = veryHigh/totalLoc*100;

	if( pM > 50 || pH > 15 || pV > 5 ){
		result = 1;	
	}else if( pM > 40 && pM <= 50 || pH > 10 && pH <= 15  || pV > 0 && pV <= 5 ){
		result = 2;	
	}else if( pM > 30 && pM <= 40 || pH > 5 && pH <= 10 ){
		result = 3;	
	}else if( pM > 25 && pM <= 30 || pH > 0 && pH <= 5 ){
		result = 4;	
	}else if( pM < 25 ){
		result = 5;	
	}
		
    return <result, sort(methodCCs, bool(tuple[loc,int,int] a, tuple[loc,int,int] b){ return a[2] > b[2]; }), <pL, pM, pH, pV>>;
}
