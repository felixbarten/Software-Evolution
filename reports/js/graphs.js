for (var project in projects) {
	var data = projects[project];
	console.log(project);
	console.log(data);	// returned object in screenshot

	//Regular pie chart example
	nv.addGraph(function() {
	  var chart = nv.models.pieChart()
	      .x(function(d) { return d.label })
	      .y(function(d) { return d.value })
	      .showLabels(true);
	
		var selectorStr = "#" + project + "cc" + " svg";
		console.log(selectorStr);
	    d3.select(selectorStr)
	        .datum(data.cc)
	        .transition().duration(350)
	        .call(chart);
	
	  return chart;
	});
}

function first(obj) {
	for (var a in obj) return a;
}
