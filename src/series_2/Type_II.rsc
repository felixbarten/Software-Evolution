module series_2::Type_II

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import Prelude; 
import IO;
import Set;

public void detectClones() {
	//loc project = |project://smallsql0.21_src|;
	loc project = |project://JavaTest|;
	

	println("Analyzing project <project>");
	M3 model = createM3FromEclipseProject(project);
	set[Declaration] ast = createAstsFromEclipseProject(project, true);
	
	//iprintln(ast);
	
	ast = rewriteAST(ast);

	
	/*
	visit(ast) {
		case \simpleName(_) t : {
			println(t);
			insert \simpleName("dfasdfasdfa");
		}
	};
	*/
	
	// iprintln(ast)
	loc filename = |project://Software-Evolution/astprettyprint.txt|;
	writeFile(filename);
	iprintToFile(filename, ast);
}

test bool rewriteVariable() {
	set[Declaration] AST = {\vararg(lang::java::jdt::m3::AST::long(), "")};
	
	rewritten = rewriteAST(AST);
	iprintln(rewritten);
	return (AST != rewritten);
}
test bool rewriteName() {
	set[Declaration] AST = {\vararg(lang::java::jdt::m3::AST::long(), "")};
	
	rewritten = rewriteAST(AST);
	iprintln(rewritten);
	return (AST != rewritten);
}
test bool rewriteModifier() {
	set[Declaration] AST = {\class([\vararg(lang::java::jdt::m3::AST::long(), "")])[@modifiers=[lang::java::jdt::m3::AST::\private()]]};
	
	rewritten = rewriteAST(AST);
	iprintln(rewritten);
	return (AST != rewritten);
}

set[Declaration] rewriteAST (set[Declaration] ast) {
	str unifiedname = "detectthis";
	a = visit(ast) {
		//case unionType(_) => unionType([short()])
		case Type _ => lang::java::jdt::m3::AST::short() 
		case Modifier _ => lang::java::jdt::m3::AST::\private()
		case \simpleName(_) => \simpleName(unifiedname)
		case \method(returntype, name, parameters, exceptions, impl) => \method (returntype, unifiedname, parameters, exceptions, impl)
		case \method(returntype, name, parameters, exceptions) => \method(returntype, unifiedname, parameters, exceptions)
		case \class(name, extends, implements, body) => \class(unifiedname, extends, implements, body)
		
		case \methodCall(isSuper, name, arguments) => \methodCall(isSuper, unifiedname, arguments)
    	case \methodCall(isSuper, receiver, name, arguments) => \methodCall(isSuper, receiver, unifiedname, arguments)
	};
	return a;
}

