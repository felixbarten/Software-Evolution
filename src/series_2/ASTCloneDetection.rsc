module series_2::ASTCloneDetection

import Prelude;
import util::Math;
import DateTime;

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;
import lang::java::m3::Core;

import series_2::misc::util;
import series_2::misc::datatypes;
import series_2::Type_II;
import series_2::Printing;

int WEIGHT_THRESHOLD = 35;
real SIMILARITY_THRESHOLD = 0.7;

 public rel[snip, snip] getClonePairs(loc project) {
	map[value, snips] m = ();
	set[node] asts = createAstsFromEclipseProject(project, false);

	rel[snip, snip] clonePairs = {};
	int subtreeWeightThreshold = WEIGHT_THRESHOLD;	
	real similarityThreshold = SIMILARITY_THRESHOLD;

	visit(asts) {
		case node a:{
			if(calcSubtreeSize(a) >= subtreeWeightThreshold){
				m = addSubtreeToMap(a,m);
			}
		}
	 }

	for(bucket <- range(m), size(bucket) > 1){
		for(tuple[snip first, snip second] pair <- sort(bucket * bucket) , pair.first != pair.second, calcSimularity(pair.first.code, pair.second.code) >= similarityThreshold){
			clonePairs = removeExistingSubtrees(pair.first.code,clonePairs);
			clonePairs = removeExistingSubtrees(pair.second.code,clonePairs);
			clonePairs += pair;
		}
	}
	
	return clonePairs;	
}

public set[set[loc]] getCloneClasses(rel[loc, loc] pairs){
    temp = pairs+;
	temp += ident(carrier(temp)); 
	temp += invert(temp);
	return determineEquivalenceClasses(temp);	
}

map[value, snips] addSubtreeToMap(subtree, map[value, rel[loc, value]] m){
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

    if(source.end.line - source.begin.line > 2){ //ignore all subtrees that aren't spread over multiple lines
        rewrittenTree = rewriteAST(subtree);
        if(m[rewrittenTree]?){
            m[rewrittenTree] += <source, subtree>;
        } else {
            m[rewrittenTree] = {<source, subtree>};
        }
    }
    return m;
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

set[value] treeToSet(value t){
	set[value] nodes = {};

	visit(t){
		case value x:{
			nodes += x;	
		}	
	}
	return nodes;
}

bool areType2Clones(snip a, snip b){
    return a.code != b.code;
}

bool areType3Clones(a, b){
    aSize = size(a);
    bSize = size(b); 
    if(!(aSize - bSize < 3 || bSize - aSize < 3)){
       return false;
    }
    return calcSimularity(a,b) > similarityThreshold; 
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

test bool calculateSubtreeSizeTest(int c){
	if ( c <= 0){
		c = 1 - c;	
	}
	if (c > 1000){	
	 c = 1000;
	}
	node m = makeNode("f", "");
	for(int n <- [1 .. c]){
		 m = createChild(m);	
	}	
	x =	calcSubtreeSize(m);
	return c == x;	
}

//2xS/(2xS+L+R)
real calcSimularity(value l, value r){
	set[value] left = treeToSet(l);
	set[value] right = treeToSet(r);

	real nShared = toReal(size(left & right));
	real dNodesL = toReal(size(left - right));
	real dNodesR = toReal(size(right - left));

	return 2*nShared/(2*nShared + dNodesL + dNodesR); 
}

test bool calcSimilarityTest1(node b)= calcSimularity(b,b) == 1.0;	

test bool calcSimilarityTest2(){
	node a = makeNode("a", "1");
	node b = makeNode("b", "2");
	return calcSimularity(a,b) == 0.0;	
}

private node createChild(node n) = makeNode("f", n );
