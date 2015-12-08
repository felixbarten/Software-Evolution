module series_2::ASTCloneDetection

import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;
import lang::java::m3::Core;
import util::Math;
import series_2::Type_II;


alias snip = tuple[ loc location, value code];
public set[node] asts = {};


private set[Declaration] normalizeAst(set[Declaration] ast){
	visit(ast){
	//	case \type(_) => \type(\int())
	default: ;
	}
}
 
public void printSnips (rel[snip, snip] clones){
	for (tuple[snip, snip] clone <- clones) {
		iprintln("");	
		iprint(clone[0].location);
		iprint(" - "); 
		iprint(clone[1].location);
	}
}

public rel[snip, snip] getDups(loc project) {
	map[value, rel[loc, value]] m = ();
	asts =  rewriteAST(createAstsFromEclipseProject(project, true));
	rel[snip, snip] clonePairs = {};
	int subTreeSizeThreshold = 10;	
	real similarityThreshold = 0.5;

	void addSubtreeToMap(subtree){
		loc source;
		
		try{
			switch(subtree){
				case Declaration a:	source = a@src;
				case Statement a:	source = a@src;
				case Expression a:	source = a@src;
				case Modifier a:	source = a@src;
			}
		} catch: source = |unknown:///|;	

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
					if(ast.code != subtree){
					clonePairs = {< l, r> | < snip l,snip  r> <-clonePairs, r.code != subtree,l.code != subtree}; 
					}
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
	
	return clonePairs;	
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

//2xS/(2xS+L+R)
real calcSimularity(node l, node r){
	set[node] left = treeToSet(l);
	set[node] right = treeToSet(r);

	real nShared = toReal(size(left & right));
	real dNodesL = toReal(size(left)- nShared);
	real dNodesR = toReal(size(right) - nShared);

	return 2*nShared/(2*nShared + dNodesL + dNodesR); 
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

test bool calcSimilarityTest1(node b){
	return calcSimularity(b,b) == 1.0;	
}

test bool calcSimilarityTest2(){
	node a = makeNode("a", "1");
	node b = makeNode("b", "1");
	return calcSimularity(a,b) == 0.0;	
}

private node createChild(node n){
	return makeNode("f", n );
}