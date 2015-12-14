module series_2::Subtrees

import Prelude;

import series_2::misc::util;

public set[value] treeToSet(value t){
	set[value] nodes = {};
	visit(t){
		case value x:{
			nodes += x;	
		}	
	}
	return nodes;
}


public int calcSubtreeSize(node n){
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