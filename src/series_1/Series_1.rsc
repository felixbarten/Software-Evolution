module series_1::Series_1

import lang::java::jdt::m3::Core;

public void createModel() {
	myModel = createM3FromEclipseProject(|project://smallsql0.21_src|);
	
	
	myModel2 = createM3FromEclipseProject(|project://hsqldb-2.3.1|);
	
}