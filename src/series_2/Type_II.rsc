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

set[Declaration] rewriteAST (set[Declaration] ast) {
	str uniformstr = "str";
	bool uniformbool = true;
	str uniformchar = "c";
	str uniformint = "1";
	
	a = visit(ast) {
		//case unionType(_) => unionType([short()])
		case Type _ => lang::java::jdt::m3::AST::short() 
		case Modifier _ => lang::java::jdt::m3::AST::\private()
		case \simpleName(_) => \simpleName(uniformstr)
		// classes
		case \class(name, extends, implements, body) => \class(uniformstr, extends, implements, body)
		// methods
		case \method(returntype, name, parameters, exceptions, impl) => \method (returntype, uniformstr, parameters, exceptions, impl)
		case \method(returntype, name, parameters, exceptions) => \method(returntype, uniformstr, parameters, exceptions)
		case \methodCall(isSuper, name, arguments) => \methodCall(isSuper, uniformstr, arguments)
    	case \methodCall(isSuper, receiver, name, arguments) => \methodCall(isSuper, receiver, uniformstr, arguments)
    	//variables
		case \variable(name, extraDimensions) => \variable(uniformstr, extraDimensions)
    	case \variable(name,  extraDimensions, init) => variable(uniformstr, extraDimensions, init)
    	// literals
    	case \booleanLiteral(boolValue) => \booleanLiteral(uniformbool)
   		case \stringLiteral(stringValue) => \stringLiteral(uniformstr)
        case \characterLiteral(charValue) => \characterLiteral(uniformchar)
        case \number(numVal) => \number(uniformint)
    
    	
    	/*
    	case node n : {
    		if(n@typ?){ 
    			println("type found");
    		}
    		if(n@modifiers?){ 
    			println("modifier found");
    		}
    	}
    	*/
	};
	return a;
}
test bool rewriteVariable() {
	set[Declaration] AST = {\vararg(lang::java::jdt::m3::AST::long(), "")};
	
	rewritten = rewriteAST(AST);
	return (AST != rewritten);
}
test bool rewriteName() {
	set[Declaration] AST = {\vararg(lang::java::jdt::m3::AST::long(), "")};
	
	rewritten = rewriteAST(AST);
	return (AST != rewritten);
}
test bool rewriteModifier() {
	set[Declaration] AST = {\class([\vararg(lang::java::jdt::m3::AST::long(), "")])[@modifiers=[lang::java::jdt::m3::AST::\private()]]};
	
	rewritten = rewriteAST(AST);
	return (AST != rewritten);
}

test bool rewriteLiteralBool() {
	AST = getTestAST();
	rewritten = rewriteAST(AST);
	visit(rewritten) {
		case \booleanLiteral(val): return val == true;
	};
	return (AST != rewritten);
}

test bool rewriteLiteralStr() {
	AST = getTestAST();
	rewritten = rewriteAST(AST);
	visit(rewritten) {
		case \stringLiteral(val): return val == "str";
	};
	return (AST != rewritten);
}

test bool rewriteLiteralChar() {
	AST = getTestAST();
	rewritten = rewriteAST(AST);
	visit(rewritten) {
		case \characterLiteral(val): return val == "c";
	};
	return (AST != rewritten);
}

test bool rewriteLiteralInt() {
	AST = getTestAST();
	rewritten = rewriteAST(AST);
	visit(rewritten) {
		case \number(val): return val == "1";
	};
	return (AST != rewritten);
}
value getTestAST() {
	set[Declaration] AST = {\class(
                    [
	                    variables(lang::java::jdt::m3::AST::\int(), [variable("testvar1", 0, number("300"))]),
	                    variables(lang::java::jdt::m3::AST::\string(), [variable("testvar2", 0, stringLiteral("testbal2"))]),
	                    variables(lang::java::jdt::m3::AST::\char(), [variable("testvar3", 0, characterLiteral("c"))]),
	                    variables(lang::java::jdt::m3::AST::\boolean(), [variable("testvar4", 0, booleanLiteral(false))])
                    ])
    };
    return AST;
}


