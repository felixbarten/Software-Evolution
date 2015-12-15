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
import series_1::MComplexity;

//int WEIGHT_THRESHOLD = 1; //Doubt we will ever need this

real SIMILARITY_THRESHOLD = 0.7;
int SLOC_THRESHOLD = 6;
int MAX_SLOC_VARIATION = 2;

public rel[snip, snip] type1ClonePairs = {};
public rel[snip, snip] type2ClonePairs = {};
public rel[snip, snip] type3ClonePairs = {};

 public rel[snip, snip] getClonePairs(loc project) {

	set[node] asts = createAstsFromEclipseProject(project, false);
	real similarityThreshold = SIMILARITY_THRESHOLD;
	maps = createCloneMaps(asts);
    
	map[codeAst, snips] cloneMap = maps.c;
    map[att, set[codeAst]] metricMap = maps.m;

	rel[snip, snip] clonePairs = {};

    rel[codeAst, codeAst] clonePairs3 = {};	
    
    attributes = domain(metricMap);

	for(att n <- attributes){
	    int begin = n.sloc-MAX_SLOC_VARIATION;
	    int end = n.sloc+MAX_SLOC_VARIATION;
        candidateRange = [begin..end];	

        codeSubset = {};
        for(i <- candidateRange, metricMap[<i,n.cc>]?){
            codeSubset += metricMap[<i,n.cc>];
        }
        product = codeSubset * codeSubset;

        clonePairs3 += {<l,r>| <l,r> <- product, size(product) > 1 && l != r && areType3Clones(l,r, SIMILARITY_THRESHOLD)};
	}

	for(bucket <- range(cloneMap), size(bucket) > 1){
		//for(cpair pair <- sort(bucket * bucket) , pair.first != pair.second, calcSimularity(pair.first.code, pair.second.code) >= similarityThreshold){
		for(cpair pair <- sort(bucket * bucket), pair.first != pair.second){
			clonePairs = removeExistingSubtrees(pair.first.code,clonePairs);
			clonePairs = removeExistingSubtrees(pair.second.code,clonePairs);
			clonePairs += pair;
		}
	}

    cleanPairs = cleanup(clonePairs);
    type1ClonePairs = {p | cpair p <- cleanPairs, p.first.code == p.second.code}; 
    type2ClonePairs = {p | cpair p <- cleanPairs, areType2Clones(p.first,p.second)};
    type3ClonePairs = {<<l@src, l>, <r@src, r>>  | <l,r> <- cleanup(clonePairs3)};

	return type1ClonePairs + type2ClonePairs + type3ClonePairs;	
}

rel[&T,&U] cleanup(rel[&T,&U] r){

    tmp = {};

    for(<f,s> <- r, <s,f> notin tmp, s != f)
     tmp += <f,s>;
    
    return tmp;
}

test bool testClonePairs() = size(getClonePairs(|project://testClones|)) > 1;

public cmaps createCloneMaps(asts){
    map[codeAst, snips] cloneMap = ();
    map[att, set[codeAst]] metricMap = ();

	visit(asts) {
		case node a:{
            result = addSubtreeToMaps(a, cloneMap, metricMap, generalizeAST, getSrcLocations);
            cloneMap = result[0];
            metricMap = result[1];
		}
	 }

    return <cloneMap,metricMap>;
}
//TODO this may be wrong
public set[set[loc]] getCloneClasses(rel[loc, loc] pairs){

    temp = pairs+;
	temp += ident(carrier(temp)); 
	temp += invert(temp);

	return determineEquivalenceClasses(temp);	
}

public node generalizeAST(ast){
    return rewriteAST(ast);
}   

cmaps addSubtreeToMaps(subtree, map[codeAst, snips] clones,map[att, set[codeAst]] metrics, astTransformFunction, retrieveLocation){
    loc source = retrieveLocation(subtree);
    int SLOCs = 0; 

    if(source != getUnknownLoc()){
        SLOCs = getLOCAstSubTree(source);
    } 

    if( (source.end.line - source.begin.line > 6) && SLOCs >= SLOC_THRESHOLD){ //ignore all subtrees that aren't spread over multiple lines
        rewrittenTree = astTransformFunction(subtree);
 //       if(calcSubtreeSize(subtree) > 30){ 
        if(true){ 
            cc = calcMethodCC(subtree);
            if(metrics[<SLOCs,cc>]?){
                metrics[<SLOCs,cc>] += subtree;
            } else {
                metrics[<SLOCs,cc>] = {subtree};
            }
        }
        if(clones[rewrittenTree]?){
            clones[rewrittenTree] += <source, subtree>;
        } else {
            clones[rewrittenTree] = {<source, subtree>};
        }
    }
    return <clones,metrics>;
}

loc getSrcLocations(node subtree){
    loc source;
    try{
        switch(subtree){
            case Declaration a: source = a@src;
            case Statement a: source = a@src;
            case Expression a: source = a@src;
            case Modifier a: source = a@src;
            default : source = getUnknownLoc();
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