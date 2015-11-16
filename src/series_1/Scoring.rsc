module series_1::Scoring

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

public int calcAnalysability(int volume, int duplicates, int unitsizes, int testcoverage) =  (volume + duplicates + unitsizes + testcoverage)/4;

public int calcChangeability(int complexity, int duplicates)= (complexity + duplicates)/2;

public int calcStability(int testcoverage) = testcoverage;

public int calcTestability(int complexity, int duplicates, int testcoverage)= (complexity + duplicates + testcoverage)/3; 


