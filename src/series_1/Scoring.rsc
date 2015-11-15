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

public int calcAnalysability(int v, int d, int u, int t) =  (v + d + u + t)/4;

public int calcChangeability(int c, int d)= (c+d)/2;

public int calcStability(int t) = t;

public int calcTestability(int c, int d, int t)= (c+d+t)/3; 


