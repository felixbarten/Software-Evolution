module series_2::Similarity

import Prelude;
import util::Math;

import series_2::misc::util;
import series_2::misc::datatypes;
import series_2::Subtrees;

@doc{
    Calculates the similarity of two subtrees
    Similarity = 2xS/(2xS+L+R)
 }
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

//Check for exact clones
bool areType1Clones(snip a, snip b) = a.code == b.code; 

// PAY ATTENTION: WRONG FOR TYPE3 DOES NOT NORMALIZE
bool areType2Clones(snip a, snip b) = !areType1Clones(a,b);

//Uses similarity between to determine if type 3
bool areType3Clones(a, b, similarityThreshold){
    simularity = calcSimularity(a,b); 
    return simularity >= similarityThreshold && simularity <= 1.0; 
}  