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

    println("Starting...\n");

	set[node] asts = createAstsFromEclipseProject(project, false);
	real similarityThreshold = SIMILARITY_THRESHOLD;

    println("Collecting clone maps...\n");

	maps = createCloneMaps(asts);
    
	map[codeAst, snips] cloneMap = maps.c;
    map[att, set[codeAst]] metricMap = maps.m;

	rel[snip, snip] clonePairs = {};

    rel[codeAst, codeAst] clonePairs3 = {};	
    
    attributes = domain(metricMap);
    real total3 = size(attributes) * 1.0;
    println("Gathering Type 3 clones...");
    int count = 0;
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
        count += 1;
        println("Progress: <round(count*1.0/total3*100,0.1)>%"); 
	}
    println("Progress: 100% (Type 3 complete)\n"); 
    cloneMapDomain = range(cloneMap); 
    real total12 = size(cloneMapDomain) * 1.0; 
    println("Gathering Type 1 and 2 clones...");
    count = 0;
	for(bucket <- cloneMapDomain, size(bucket) > 1){
		//for(cpair pair <- sort(bucket * bucket) , pair.first != pair.second, calcSimularity(pair.first.code, pair.second.code) >= similarityThreshold){
		for(cpair pair <- sort(bucket * bucket), pair.first != pair.second){
			clonePairs = removeExistingSubtrees(pair.first.code,clonePairs);
			clonePairs = removeExistingSubtrees(pair.second.code,clonePairs);
			clonePairs += pair;
		}
		count += 1;
        println("Progress: <round(count*1.0/total12*100,0.1)>%"); 
	}
    println("Progress: 100% (Type 1 + 2)\n"); 

    cleanPairs = removeBlocksIfEntireMethodPresent(clonePairs);

    type1ClonePairs = {p | cpair p <- cleanPairs, p.first.code == p.second.code}; 
    println("Type 1#: <size(type1ClonePairs)>");

    type2ClonePairs = {p | cpair p <- cleanPairs, areType2Clones(p.first,p.second)};
    println("Type 2#: <size(type2ClonePairs)>");

    type3ClonePairs = {<<l@src, l>, <r@src, r>>  | <l,r> <- removeBlocksIfEntireMethodPresent(clonePairs3)};
    println("Type 3#: <size(type3ClonePairs)>/n");
    println("Clone detection complete");

	return type1ClonePairs + type2ClonePairs + type3ClonePairs;	
}


rel[value,value] cleanup(rel[value,value] r){

    rel[value, value] tmp = {};

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
            cc = calcSubtreeCC(subtree);
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
rel[snip,snip] removeBlocksIfEntireMethodPresent(rel[snip,snip] clonePairs){
    set[snip] allSnips =  carrier(clonePairs);
    blocks = {b.code| snip b <- allSnips, \block := b.code};

    for(snip m <- allSnips, \method(_,_,_,_,b) := m.code, b in blocks) {
        clonePairs = {<l,r> | < snip l, snip r> <- clonePairs, \block := l.code || \block  := r.code, l.code != b, r.code != b};
    }

    return clonePairs;
}
rel[codeAst,codeAst] removeBlocksIfEntireMethodPresent(rel[codeAst,codeAst] clonePairs){
    set[codeAst] allCode =  carrier(clonePairs);
    blocks = {b| codeAst b <- allCode, \block := b};

    for(codeAst m <- allCode, \method(_,_,_,_,b) := m, b in blocks) {
        clonePairs = {<l,r> | < codeAst l, codeAst r> <- clonePairs, \block := l || \block  := r, l != b, r != b};
    }

    return clonePairs;
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