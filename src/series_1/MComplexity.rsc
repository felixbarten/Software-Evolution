module series_1::MComplexity

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;

import series_1::Series_1;

public int calcMethodCC(methodAST){

	int i = 1;

	visit(methodAST){
		case "if"(_, _) : i = i +1;
		case "if"(_, _,_) : i = i +1;
		case "do"(_, _,_) : i = i +1;
		case "conditional"(_, _,_) : i = i +1;
		case "while"(_, _) : i = i +1;
		case "for"(_, _, _) : i = i +1;
		case "for"(_, _, _, _) : i = i +1;
		case "foreach"(_, _, _) : i = i +1;
		case "try"(_, _) : i = i +1;
		case "try"(_, _, _) : i = i +1;
		case "case"(_) : i = i +1;
		case "defaultCase"() : i = i +1;
		case "infix"(_,"&&",_) : i = i +1;
		case "infix"(_,"||",_) : i = i +1;
	}

	return i;
} 

test bool t1(){
	myModel = createM3FromEclipseProject(|project://testJava/|);
	totalLoc = 47;
	result = calcCCScore(47, myModel); 	
	return result[0] == 5;
}

public list[tuple[str,int,int]] calcProjectCC(M3 input){
	 model = input;
	 return for(m <- methods(model)){
	 	methodAST = getMethodASTEclipse(m,model=model);
	 	append <m.path, getLOC(m, false)[0], calcMethodCC(methodAST)>;
	 }
}

public tuple[int,lrel[str,int,int]] calcCCScore(totalLoc, M3 model){

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

	/* Thresholds
		<50,15,5>
		<40,10,0>
		<30, 5,0>
		<25, 0,0>
	*/
	
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
		
    return <result, take(3,sort(methodCCs, bool(tuple[str,int,int] a, tuple[str,int,int] b){ return a[2] > b[2]; }))>;
}