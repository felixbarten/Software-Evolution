module series_2::ASTCloneDetection

import Prelude;
import util::Math;
import DateTime;

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;
import lang::java::m3::Core;


import series_2::Similarity;
import series_2::misc::util;
import series_2::misc::datatypes;
import series_2::Type_II;
import series_2::Printing;
import series_2::Subtrees;

import series_1::LOC;

int WEIGHT_THRESHOLD = 1;
real SIMILARITY_THRESHOLD = 0.7;

 public rel[snip, snip] getClonePairs(loc project) {

	set[node] asts = createAstsFromEclipseProject(project, false);
	real similarityThreshold = SIMILARITY_THRESHOLD;

	map[value, snips] cloneMap = createCloneMap(asts);
	rel[snip, snip] clonePairs = {};

	for(bucket <- range(cloneMap), size(bucket) > 1){
		for(tuple[snip first, snip second] pair <- sort(bucket * bucket) , pair.first != pair.second, calcSimularity(pair.first.code, pair.second.code) >= similarityThreshold){
			clonePairs = removeExistingSubtrees(pair.first.code,clonePairs);
			clonePairs = removeExistingSubtrees(pair.second.code,clonePairs);
			clonePairs += pair;
		}
	}
	return clonePairs;	
}

test bool testClonePairs() = size(getClonePairs(|project://testClones|)) > 1;

public map[value, snips] createCloneMap(asts){
    map[value, snips] cloneMap = ();
	int subtreeWeightThreshold = WEIGHT_THRESHOLD;	

	visit(asts) {
		case node a:{
			if(calcSubtreeSize(a) >= subtreeWeightThreshold){
				cloneMap = addSubtreeToMap(a,cloneMap, generalizeAST, getSrcLocations);
			}
		}
	 }

    return cloneMap;
}

public set[set[loc]] getCloneClasses(rel[loc, loc] pairs){

    temp = pairs+;
	temp += ident(carrier(temp)); 
	temp += invert(temp);

	return determineEquivalenceClasses(temp);	
}

public node generalizeAST(ast){
    return rewriteAST(ast);
}   

map[value, snips] addSubtreeToMap(subtree, map[value, rel[loc, value]] m, astTransformFunction, retrieveLocation){
    loc source = retrieveLocation(subtree);
    int SLOCs = 0; 

    if(source != getUnknownLoc()){
        SLOCs = getLOCAstSubTree(source);
    } 

    if(SLOCs >= 6){ //ignore all subtrees that aren't spread over multiple lines
        rewrittenTree = astTransformFunction(subtree);
        if(m[rewrittenTree]?){
            m[rewrittenTree] += <source, subtree>;
        } else {
            m[rewrittenTree] = {<source, subtree>};
        }
    }
    return m;
}

loc getSrcLocations(node subtree){
    loc source;
    try{
        switch(subtree){
            case Declaration a: source = a@src;
            case Statement a: source = a@src;
            case Expression a: source = a@src;
            case Modifier a: source = a@src;
            case node _: source = getUnknownLoc();
        }
    } catch: source = getUnknownLoc(); //The element had no src annotation
    return source;
}

test bool getSrcLocationTest(){
    loc source = |project://TestLocation|;
	Declaration ast = \vararg(lang::java::jdt::m3::AST::long(), "");
	ast@src= source; 
	return getSrcLocations(ast) == source;
}

test bool getSrcLocationTest2(){
	Declaration ast = \vararg(lang::java::jdt::m3::AST::long(), "");
	return getSrcLocations(ast) == getUnknownLoc();
}

rel[snip,snip] removeExistingSubtrees(ast, rel[snip,snip] clonePairs){
    visit(ast) {
        case node subtree:{
            if(subtree != ast){
               clonePairs -= {<l,r> | <snip l, snip r> <-clonePairs, r.code == subtree || l.code == subtree}; 
            }
        }
    }
    return clonePairs;
}