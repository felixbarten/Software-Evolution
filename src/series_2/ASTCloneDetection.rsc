module series_2::ASTCloneDetection

import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;
import lang::java::m3::Core;
import util::Math;


alias snip = tuple[node, loc];
public set[Declaration] asts = {};
//public map[node, tuple[loc,set[node]]] bucket = ();
public map[node, set[node]] bucket = ();
 
public set[node] getDups(loc project) {
	map[node, rel[loc,node]] m = ();
	asts =  createAstsFromEclipseProject(project, true);
	rel[snip] clonePairs = [];
	int subTreeSizeThreshold = 4;	
	void addSubTreeToMap(map m, node a){
			if( calcSubtreeSize(a) >= subTreeSizeThreshold){
				loc source = |null://null|;
					if(a@src?){ 	
						source = a@src;
					}

				if(m[a]?){
					m[a] += <source, a>;
				} else {
					m[a] = {<source, a>};
				}
			}
	}

	bottom-up visit(asts) {
		case Declaration a:{
			addSubtreeToMap(m,a);
		}
		case Statement a:{
			addSubtreeToMap(m,a);
		}
		case Expression a:{
			addSubtreeToMap(m,a);
		}
	 }

	bottom-up visit(asts) {
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

	 for(b <- range(bucket), size(b) >= 2){
		iprintln();
	 }
	
	iprintln(asts);	
	iprintln(size(clonePairs));
	//return lol;
	return {};	
}

set[node] treeToSet(node t){
	set[node] t = {};

	visit(t){
		case node x:{
			t += x;	
		}	
	}
	return t;
}

//2xS/(2xS+L+R)
real calcSimularity(node l, node r){
	set[node] left = treeToSet(l);
	set[node] right = treeToSet(r);
	real nShared = toReal(size(left & right));

	return 2*nShared/(2*nShared + size(l) + size(r)); 
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