module series_2::ASTCloneDetection

import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;
import lang::java::m3::Core;
import util::Math;


alias snip = tuple[ loc location, value code];
public set[node] asts = {};
//public map[node, tuple[loc,set[node]]] bucket = ();
public map[node, set[node]] bucket = ();



private set[Declaration] normalizeAst(set[Declaration] ast){

	visit(ast){
	//	case \type(_) => \type(\int())
	default: ;
	}


}
 
public map[value, rel[loc,value]] getDups(loc project) {
	map[value, rel[loc, value]] m = ();
	asts =  createAstsFromEclipseProject(project, true);
	rel[snip, snip] clonePairs = {};
	int subTreeSizeThreshold = 2;	

	void addSubtreeToMap( value a){
			if( calcSubtreeSize(a) >= subTreeSizeThreshold){
				loc source = |project://testJava|;
					//if(a@src?){ //todo?	
					//	source = a@src;
					//}
				if(m[a]?){
					m[a] += <source, a>;
				} else {
				    rel[loc, value] b = {<source, a>};
					m[a] = b;
				}
			}
	}
	

	bottom-up visit(asts) {
		case node a:{
			addSubtreeToMap(a);
		}
	 }

/*	bottom-up visit(asts) {
		case node a:{
			if( calcSubtreeSize(a) >= subTreeSizeThreshold){
					  if(a notin bucket){
					//bucket += (a: <a@src,{}>);
						bucket += (a: {a});
					  } else {
					//bucket[a][1] += a;	
						bucket[a] += a;	
					  }
			}
		}
	 }
*/
	
	 void removeExistingSubtree(ast){
		bottom-up visit(ast) {
			case node subtree:{
				clonePairs = {< l,  r> | < snip l,snip  r> <-clonePairs, r.code != subtree}; 
			}
		}
	 }
	 cand = domain(m);
	//SimThreshold = 0.375
		for(tuple[node first, node second] pair <- cand * cand , pair.first != pair.second, calcSimularity(pair.first,pair.second) >= 0.375){
			removeExistingSubtree(pair.first);
			removeExistingSubtree(pair.second);
			clonePairs += m[pair.first] * m[pair.second];
		}
	
	iprintln(size(clonePairs));
	return m;	
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

	return 2*nShared/(2*nShared + size(left) + size(right)); 
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

node createChild(node n){
	return makeNode("f", n );
}