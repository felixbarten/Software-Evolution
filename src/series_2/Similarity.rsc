module series_2::Similarity

import Prelude;
import util::Math;

import series_2::misc::util;
import series_2::misc::datatypes;
import series_2::Subtrees;

// Similarity = 2xS/(2xS+L+R)
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

test bool calcSimilarityTest3(){
	node a = makeNode("a", "1");
	node b = makeNode("b", "1");
	return calcSimularity(a,b) == 0.5;	
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