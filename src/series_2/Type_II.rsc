module series_2::Type_II

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import Prelude; 
import IO;
import Set;

alias snip = tuple[ loc location, value code];

set[node] rewriteASTs (set[node] ast) = { rewriteAST(res) | res <- ast };

node rewriteAST ( node ast) {
	str uniformstr = "str";
	bool uniformbool = true;
	str uniformchar = "c";
	str uniformint = "1";
	
	node a = visit(ast) {
		//case unionType(_) => unionType([short()])
		case Type _ => lang::java::jdt::m3::AST::short() 
		case Modifier _ => lang::java::jdt::m3::AST::\private()
		case \simpleName(_) => \simpleName(uniformstr)

		// classes
		case \class(name, extends, implements, body) => \class(uniformstr, extends, implements, body)

		// methods
		//case \method(returntype, name, parameters, exceptions, impl) => \method (lang::java::jdt::m3::AST::short(), uniformstr, parameters, exceptions, impl)
		//case \method(returntype, name, parameters, exceptions) => \method(lang::java::jdt::m3::AST::short(), uniformstr, parameters, exceptions)

		case \method(returntype, name, parameters, exceptions, impl) => \method (lang::java::jdt::m3::AST::short(), name, parameters, exceptions, impl)
		case \method(returntype, name, parameters, exceptions) => \method(lang::java::jdt::m3::AST::short(), name, parameters, exceptions)
    	//variables
		case \variable(name, extraDimensions) => \variable(uniformstr, extraDimensions)
    	case \variable(name,  extraDimensions, init) => variable(uniformstr, extraDimensions, init)

    	// literals
    	case \booleanLiteral(boolValue) => \booleanLiteral(uniformbool)
   		case \stringLiteral(stringValue) => \stringLiteral(uniformstr)
        case \characterLiteral(charValue) => \characterLiteral(uniformchar)
        case \number(numVal) => \number(uniformint)
	};
	return a;
}





// TESTS


test bool rewriteVariable() {
	set[Declaration] AST = {\vararg(lang::java::jdt::m3::AST::long(), "")};
	
	rewritten = rewriteASTs(AST);
	return (AST != rewritten);
}
test bool rewriteName() {
	set[Declaration] AST = {\vararg(lang::java::jdt::m3::AST::long(), "")};
	
	rewritten = rewriteASTs(AST);
	return (AST != rewritten);
}
test bool rewriteModifier() {
	set[Declaration] AST = {\class([\vararg(lang::java::jdt::m3::AST::long(), "")])[@modifiers=[lang::java::jdt::m3::AST::\private()]]};
	
	rewritten = rewriteASTs(AST);
	return (AST != rewritten);
}

test bool rewriteLiteralBool() {
	AST = getTestAST();
	rewritten = rewriteASTs(AST);
	visit(rewritten) {
		case \booleanLiteral(val): return val == true;
	};
	return (AST != rewritten);
}

test bool rewriteLiteralStr() {
	AST = getTestAST();
	rewritten = rewriteASTs(AST);
	visit(rewritten) {
		case \stringLiteral(val): return val == "str";
	};
	return (AST != rewritten);
}

test bool rewriteLiteralChar() {
	AST = getTestAST();
	rewritten = rewriteASTs(AST);
	visit(rewritten) {
		case \characterLiteral(val): return val == "c";
	};
	return (AST != rewritten);
}

test bool rewriteLiteralInt() {
	AST = getTestAST();
	rewritten = rewriteASTs(AST);
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


