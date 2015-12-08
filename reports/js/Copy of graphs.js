	//var data = projects[project];
	//console.log(project);
	//console.log(data);	// returned object in screenshot
	
	// workaround because for loop doesnt work. 
	// hardcoded values for now because regardless of I it will just pick last value in array.
	var keys = Object.keys(projects);
	var i = 0;

	//Regular bar chart
	nv.addGraph(function() {
	  var chart = nv.models.discreteBarChart()
	      .x(function(d) { return d.label })    //Specify the data accessors.
	      .y(function(d) { return d.value })
	      .staggerLabels(true)    //Too many bars and not enough room? Try staggering labels.
	      .tooltips(false)        //Don't show tooltips
	      .showValues(true)       //...instead, show the bar value right on top of each bar.
	      .transitionDuration(350)
	      ;
	
	  d3.select('#chart svg')
	      .datum(exampleData())
	      .call(chart);
	
	  nv.utils.windowResize(chart.update);
	
	  return chart;
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
