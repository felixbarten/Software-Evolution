module series_1::MComplexity

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

public value calcProjectCC(loc location){
	 model = createM3FromEclipseProject(location);
	 return for(m <- methods(model)){
	 	methodAST = getMethodASTEclipse(m,model=model);
	 	append <m, getLOC(m)[0], calcMethodCC(methodAST)>;
	 }
}