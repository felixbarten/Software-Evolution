module series_1::Series_1

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Prelude;


public void createAST() {
	int LOC = 0;
	//projectAST = createAstsFromEclipseProject(|project://smallsql0.21_src|, true);
	
//	projectAST = createAstsFromEclipseProject(|project://RascalTestProject|, true);
		
	projectAST = createAstsFromEclipseProject(|project://JavaTest2|, true);
	iprintln(projectAST);
	visit (projectAST) {
		case \assert(_): LOC += 1; 
	    case \assert(_, _): LOC += 1; 
	    case \block(_, _): LOC += 1; 
	    case \break() : LOC += 1; 
	    case \break(_) : LOC += 1; 
	    case \continue(): LOC += 1; 
	    case \continue(_): LOC += 1; 
	    case \do(_, _): LOC += 1; 
	    case \empty(): LOC += 1; 
	    case \foreach(_, _, _): LOC += 1; /// declaration?
	    case \for(_, _,_ ,_): LOC += 1; 
	    case \for(_, _, _): LOC += 1; 
	    case \if(_ , _): LOC += 1; 
	    case \if(_ , _, _ ): LOC += 1; 
	    case \label(_, _): LOC += 1; 
	    case \return(_): LOC += 1; 
	    case \return(): LOC += 1; 
	    case \switch(_,_): LOC += 1; 
	    case \case(_): LOC += 1; 
	    case \defaultCase(): LOC += 1; 
	    case \synchronizedStatement(_) : LOC += 1; 
	    case \throw(_) : LOC += 1; 
	    case \try(_, _ ): LOC += 2; 
	    case \try(_ , _, _): LOC += 2;                                       
	    case \catch(_, _): LOC += 2; 			// declaration?
//	    case \declarationStatement(_): LOC += 0; // declaration
	    case \while(_, _): LOC += 1; 
	    case \expressionStatement(_): LOC += 1; 
	    case \constructorCall(_, _,_): LOC += 1; 
	    case \constructorCall(_, _): LOC += 1;
	    //declarations::: 
//		case \compilationUnit(_, _): LOC += 0;
	    case \compilationUnit(_, _, _): LOC += 1;
	    case \enum(_, _, _, _): LOC += 1;
	    case \enumConstant(_, _, _): LOC += 1;
	    case \enumConstant(_, _): LOC += 1;
	    case \class(_, _, _, _): LOC += 2;
	    case \class(_): LOC += 1;
	    case \interface(_, _, _, _): LOC += 1;
	    case \field(_, _): LOC += 1;
	    case \initializer(_): LOC += 1;
	    case \method(_, _, _, _, _): LOC += 0;
	    case \method(_, _, _, _): LOC += 1;
	    case \constructor(_, _, _, _): LOC += 1;
	    case \import(_): LOC += 1;
	    case \package(_): LOC += 1;
	    case \package(_, _): LOC += 1;
	    case \variables(_, _): LOC += 1;
	    case \typeParameter(_, _List): LOC += 1;
	    case \annotationType(_, _): LOC += 1;
	    case \annotationTypeMember(_, _): LOC += 1;
	    case \annotationTypeMember(_, _, _): LOC += 1;
	    case \parameter(_, _, _): LOC += 1;
	    case \vararg(_, _): LOC += 1;
//	    case /\s*}\s*/: LOC +=0;
		default: LOC+= 0;
		
	}
	println("<LOC> after visit");
	
	
	
	LOC = 0;
		
	visit(projectAST) {
		case \Statement: LOC += 1;
		case \Declaration: LOC +=1;
	}
	println("<LOC> after visit");
	
	
	for (/Statement x := projectAST)	{
		//println("Current statement: <x>");

		visit(x){
			case \declarationStatement(_): LOC += 0;
			default: LOC +=1;
		}
		
		/*
		if (Declaration !:= x){
			iprintln("Current decl: <x>");
			LOC += 1;
		} else {
			println("THIS IS S DECLARATION");
		}
		*/
		
	}
	println(LOC);
	
	
	for (/Declaration dec := projectAST) {
		LOC += 1;
	}
	println(LOC);	
}

public void getLOCs(bool debug) {
	//|project://smallsql0.21_src|
	list[loc] projects = [ |project://RascalTestProject|, |project://JavaTest2|];
	for (project <- projects) {
		getLOC(project, debug);
	}
	
}

public void getLOC(loc project, bool debug) {

	myModel = createM3FromEclipseProject(project);	
	projectAST = createAstsFromEclipseProject(project, true);

	int LOC = 0;
	int blank = 0;
	int comment = 0;
	bool incomment = false; 
	
	for (c <- classes(myModel)){ 
		srcLines = readFileLines(c); 	
		for (line <- srcLines) {	
			if (/^\s*\/\/\s*\w*/ := line) {
				if (debug)
					println("single line comment: <line>");
				comment += 1;
			} else if (/^\s*\/\*[\w\s]*\*\/$/ := line) {
				if (debug)
					println("single line multiline");
				comment += 1;
			}  else if (/^\s*\/\*[\w\s]*\*\/[\s\w]*/ := line) {
				if (debug)
					println("single line multiline with code");
				LOC += 1;
			}else if (/^\s*\/\*\s*/ := line){
				incomment = true;
				comment += 1;
				if (debug)
					println("start multiline comment");
				
			} else if (/\s*\*\/\s*$/ := line){
				if (debug)
					println("end multiline comment");
				comment += 1;
				incomment = false;
				
			} else if (/^\s*$/ := line) {
				blank += 1;
				if (debug)
					println("Blank: <line>");
			} else {
				if (!incomment) {
					if (debug)
						println("code: <line>");
					LOC += 1;
				} else {
					if (debug)
						println("comment: <line>");
					comment += 1;
				}
			}
			
		}
		
	}
	println("Results for project: <project>");
	println("Lines of Code: <LOC>");
	println("Blank lines: <blank>");
	println("Commented lines: <comment>");
}

public void getLOCFromFile(loc file, bool debug) {

	//myModel = createM3FromEclipseFile(file);	
	//projectAST = create(file, true);

	int LOC = 0;
	int blank = 0;
	int comment = 0;
	bool incomment = false; 
	
	srcLines = readFileLines(file); 	
	for (line <- srcLines) {	
		if (/^\s*\/\/\s*\w*/ := line) {
			if (debug)
				println("single line comment: <line>");
			comment += 1;
		} else if (/^\s*\/\*[\w\s]*\*\/$/ := line) {
			if (debug)
				println("single line multiline");
			comment += 1;
		}  else if (/^\s*\/\*[\w\s]*\*\/[\s\w]*/ := line) {
			if (debug)
				println("single line multiline with code");
			LOC += 1;
		}else if (/^\s*\/\*\s*/ := line){
			incomment = true;
			comment += 1;
			if (debug)
				println("start multiline comment");
				
		} else if (/\s*\*\/\s*$/ := line){
			if (debug)
				println("end multiline comment");
			comment += 1;
			incomment = false;
				
		} else if (/^\s*$/ := line) {
			blank += 1;
			if (debug)
				println("Blank: <line>");
		} else {
			if (!incomment) {
				if (debug)
					println("code: <line>");
				LOC += 1;
			} else {
				if (debug)
					println("comment: <line>");
				comment += 1;
				}
			}
			
		}
		
	println("Results for file: <file>");
	println("Lines of Code: <LOC>");
	println("Blank lines: <blank>");
	println("Commented lines: <comment>");
}


public void setup() {
	//
	myModel = createM3FromEclipseProject(	|project://RascalTestProject|);
	list[loc] parsed = [];
//	myModel = createM3FromEclipseProject(	|project://JavaTest2|);
	///iprintln(myModel);
	///iprintln(myModel@containment);
	
	for (class <- classes(myModel)) {
		list[loc] units = [c | c <- invert(myModel@containment)[class], c.scheme == "java+compilationUnit"];
	
		for (loc unit <- units){
			iprintln(unit);
			if (unit notin parsed) {
				getLOCFromFile(unit, true);
				parsed += unit;
			}
		}
	}
}
