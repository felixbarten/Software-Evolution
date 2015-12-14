module series_2::misc::util
import Prelude;
import series_2::misc::datatypes;
@doc{

   Partitions equivalence relations into equivalence classes 
}
public set[set[&T]] determineEquivalenceClasses(rel[&T, &T] a) = { e | e <- groupRangeByDomain(a), size(e)> 1};

@doc{
   Basically toString for durations 
}
public str showDuration(Duration duration) = "Total calculations completed in: <duration.years> years, <duration.months> months, <duration.days> days, <duration.hours> hours, <duration.minutes> minutes, <duration.seconds> seconds and <duration.milliseconds> milliseconds.";

@doc{
    For those seeking the location of the unknown...
}
public loc getUnknownLoc() { 
 	loc unknown = |unknown:///|;
	unknown = unknown[offset = 1];
	unknown = unknown[length = 1];
	unknown = unknown[begin = <1,1>];
	unknown = unknown[end = <11,1>];
	return unknown;
}

@doc{
    print the location of snips relations 
}
public void printSnips (rel[snip, snip] clones){
	for (tuple[snip, snip] clone <- clones) {
		iprint(clone[0].location);	
		iprint(" - ");
		iprintln(clone[1].location);	
	}
}

@doc {
	Returns list of strings unless the loc provided is unknown
}
public list[str] readSrc(loc file) {
	if (file != getUnknownLoc()) {
		return readFileLines(file);
	}
	return [];
}