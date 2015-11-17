	//var data = projects[project];
	//console.log(project);
	//console.log(data);	// returned object in screenshot
	
	// workaround because for loop doesnt work. 
	// hardcoded values for now because regardless of I it will just pick last value in array.
	var keys = Object.keys(projects);
	var i = 0;

	//Regular pie chart example
	nv.addGraph(function() {
	  var mychart = nv.models.pieChart()
	      .x(function(d) { return d.label })
	      .y(function(d) { return d.value })
	      .showLabels(true);
	
		var selectorStr = "#" + keys[0] + "cc" + " svg";
		console.log("Selector: :" + selectorStr);
	    d3.select(selectorStr)
	        .datum(projects[keys[0]].cc)
	        .transition().duration(350)
	        .call(mychart);
	
	  return mychart;
	});

	i = 1;

	//Regular pie chart example
	nv.addGraph(function() {
	  var chart = nv.models.pieChart()
	      .x(function(d) { return d.label })
	      .y(function(d) { return d.value })
	      .showLabels(true);
		console.log(i);
		
		var selectorStr = "#" + keys[1] + "cc" + " svg";
		console.log(selectorStr);
	    d3.select(selectorStr)
	        .datum(projects[keys[1]].cc)
	        .transition().duration(350)
	        .call(chart);
	
	  return chart;
	});
	//Regular pie chart example
	nv.addGraph(function() {
	  var mychart = nv.models.pieChart()
	      .x(function(d) { return d.label })
	      .y(function(d) { return d.value })
	      .showLabels(true);
	
		var selectorStr = "#" + keys[2] + "cc" + " svg";
		console.log("Selector: :" + selectorStr);
	    d3.select(selectorStr)
	        .datum(projects[keys[2]].cc)
	        .transition().duration(350)
	        .call(mychart);
	
	  return mychart;
	});
	
		//Regular pie chart example
	nv.addGraph(function() {
	  var mychart = nv.models.pieChart()
	      .x(function(d) { return d.label })
	      .y(function(d) { return d.value })
	      .showLabels(true);
	
		var selectorStr = "#" + keys[3] + "cc" + " svg";
		console.log("Selector: :" + selectorStr);
	    d3.select(selectorStr)
	        .datum(projects[keys[i]].cc)
	        .transition().duration(350)
	        .call(mychart);
	
	  return mychart;
	});
function first(obj) {
	for (var a in obj) return a;
}
