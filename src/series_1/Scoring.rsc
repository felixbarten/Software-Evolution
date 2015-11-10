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