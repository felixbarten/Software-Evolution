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
	//set[Declaration] ast = createAstsFromEclipseProject(project, true);
		
	//ast = rewriteAST(ast);

	value result = getDups(project);
	/*
	visit(ast) {
		case \simpleName(_) t : {
			println(t);
			insert \simpleName("dfasdfasdfa");
		}
	};
	*/
}
alias snip = tuple[ loc location, value code];

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
		case \method(returntype, name, parameters, exceptions, impl) => \method (lang::java::jdt::m3::AST::short(), uniformstr, parameters, exceptions, impl)
		case \method(returntype, name, parameters, exceptions) => \method(lang::java::jdt::m3::AST::short(), uniformstr, parameters, exceptions)
		//case \methodCall(isSuper, name, arguments) => \methodCall(isSuper, uniformstr, arguments)
    	//case \methodCall(isSuper, receiver, name, arguments) => \methodCall(isSuper, receiver, uniformstr, arguments)
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
public void printLOC (rel[snip, snip] clones){
	for (tuple[snip, snip] clone <- clones) {
		iprintln(clone[0][0]);
		iprintln(clone[1][0]);
		println();
	}
}

public rel[snip, snip] getDups(loc project) {
	map[value, rel[loc, value]] m = ();
	asts =  createAstsFromEclipseProject(project, true);
	asts = rewriteAST(asts);
	rel[snip, snip] clonePairs = {};
	int subTreeSizeThreshold = 10;	
	real similarityThreshold = 0.0;

	void addSubtreeToMap(subtree){
				loc source = |unknown:///|;
				
				try{
					switch(subtree){
						case Declaration a:	source = a@src;
						case Statement a:	source = a@src;
						case Expression a:	source = a@src;
						case Modifier a:	source = a@src;
					}
				} catch: iprintln("No src annotation at <subtree> \n");	

				if(m[subtree]?){
					m[subtree] += <source, subtree>;
				} else {
				    rel[loc, value] b = {<source, subtree>};
					m[subtree] = b;
				}
	}
	

	bottom-up visit(asts) {
		case node a:{
			if( calcSubtreeSize(a) >= subTreeSizeThreshold){
				addSubtreeToMap(a);
			}
		}
	 }
	 	
	 void removeExistingSubtree(ast){
		bottom-up visit(ast.code) {
			case node subtree:{
					clonePairs = {< l, r> | < snip l,snip  r> <-clonePairs, r.code != subtree,l.code != subtree}; 
			}
		}
	 }

	buckets = range(m);

	for(bucket <- buckets, size(bucket) > 1){
		for(tuple[snip first, snip second] pair <- bucket * bucket , pair.first != pair.second, calcSimularity(pair.first.code,pair.second.code) >= similarityThreshold){
			removeExistingSubtree(pair.first);
			removeExistingSubtree(pair.second);
			clonePairs += pair;
		}
	}
	
	iprintln(size(clonePairs));

	for(<l,r> <- clonePairs){
		if(l == r){
			iprintln("fuck");
		}
	}
	printLOC(clonePairs);
	printASTToFile(asts);
	
	return clonePairs;	
}

public void printASTToFile(set[Declaration] ast) {
	loc filename = |project://Software-Evolution/astprettyprint.txt|;
	writeFile(filename);
	iprintToFile(filename, ast);
}

int calcSubtreeSize(node n){
	int size = 0;
	visit (n){
		case node child:{
			 size += 1;
		}	
	}
	return size;
} 

//2xS/(2xS+L+R)
real calcSimularity(node l, node r){
	set[node] left = treeToSet(l);
	set[node] right = treeToSet(r);

	real nShared = toReal(size(left & right));
	real dNodesL = toReal(size(left)- nShared);
	real dNodesR = toReal(size(right) - nShared);

	return 2*nShared/(2*nShared + dNodesL + dNodesR); 
}

set[node] treeToSet(node t){
	set[node] r = {};

	visit(t){
		case node x:{
			r += x;	
		}	
	}
	return r;
}










// TESTS


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


