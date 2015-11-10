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

public str calcAnalysability(int v, int d, int u, int t){ return (v + d + u + t)/4;}

public str calcChangeability(int c, int d){ return (c+d)/2.0;}

public str calcStability(int t){ return t;}

public str calcTestability(int c, int d, int t){ return (c+d+t)/3; }


