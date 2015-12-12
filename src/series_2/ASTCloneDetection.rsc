module series_2::ASTCloneDetection

import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;
import lang::java::m3::Core;
import util::Math;
import DateTime;
import series_2::Type_II;
import series_2::Printing;


alias snip = tuple[ loc location, value code];


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

 loc getUnknownLoc() { 
 	loc unknown = |unknown:///|;
	unknown = unknown[offset =1];
	unknown = unknown[length = 1];
	unknown = unknown[begin=<1,1>];
	unknown = unknown[end=<11,1>];
	return unknown;
 }

 public rel[snip, snip] getDups(loc project) {
	loc report = startReport(project);

	datetime beginTime = now();
	map[value, rel[loc, value]] m = ();
	set[node] asts = rewriteAST(createAstsFromEclipseProject(project, true));
	iprintln("Size: <size(asts)>");
	rel[snip, snip] clonePairs = {};
	int subTreeSizeThreshold = 6;	
	real similarityThreshold = 0.6;

	void addSubtreeToMap(subtree){
		loc source;
		try{
			switch(subtree){
				case Declaration a:	source = a@src;
				case Statement a:	source = a@src;
				case Expression a:	source = a@src;
				case Modifier a:	source = a@src;
			}
		} catch: source = getUnknownLoc(); //The element had no src annotation
			
		if(source.end.line - source.begin.line  > 6){ //ignore all subtrees to aren't spread over 6 lines
			if(m[subtree]?){
				m[subtree] += <source, subtree>;
			} else {
				m[subtree] = {<source, subtree>};
			}
		}
	}

	visit(asts) {
		case node a:{
			if( calcSubtreeSize(a) >= subTreeSizeThreshold){
				addSubtreeToMap(a);
			}
		}
	 }
	
	 void removeExistingSubtree(ast){
		visit(ast.code) {
			case node subtree:{
				if(ast.code != subtree){ //Keep ourselves in just in case
					clonePairs = {<l, r> | < snip l,snip r> <-clonePairs, r.code != subtree,l.code != subtree}; 
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
	
	str pDur(Duration duration){
	 return durationStr = "Total calculations completed in: <duration.years> years, <duration.months> months, <duration.days> days, <duration.hours> hours, <duration.minutes> minutes, <duration.seconds> seconds and <duration.milliseconds> milliseconds.";
	}	
	
	printSnipsToFile(clonePairs, report);
	printBarGraph(clonePairs, report, project);
	printChordDiagram(clonePairs, report, project);
	
	iprintln("Found clones: <size(clonePairs)>");	
	Duration execution = createDuration(beginTime, now());
	iprintln("Execution time: <pDur(execution)>");
	printProjectExecutionTime(execution, report); 	
	endReport(report);
	return clonePairs;	
}


set[node] treeToSet(node t){
	set[node] nodes = {};

	visit(t){
		case node x:{
			nodes += x;	
		}	
	}
	return nodes;
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