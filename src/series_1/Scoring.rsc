module series_1::Scoring
import analysis::statistics::Descriptive;
import List;
import util::Math;

public str printVerdict(int verdict) {
	str strVerdict = "";
	switch(verdict) {
		case 5: 
			strVerdict = "++";
		case 4: 
			strVerdict = "+";
		case 3: 
			strVerdict = "+/-";
		case 2:
			strVerdict = "-";
		case 1: 
			strVerdict = "--";
		default:
			strVerdict = "unknown";
	}
	return strVerdict;
}

public int calcAnalysability(int volume, int duplicates, int unitsizes, int testcoverage) {  
	list[int] scores = sort([volume,duplicates,unitsizes,testcoverage]);
	return toInt(median(scores));
}

public int calcChangeability(int complexity, int duplicates){ 
	list[int] scores = sort([complexity,duplicates]);
	return toInt(median(scores));
}

public int calcStability(int testcoverage) = testcoverage;

public int calcTestability(int complexity, int duplicates, int testcoverage){
	list[int] scores = sort([complexity,duplicates, testcoverage]);
	return toInt(median(scores));
} 


