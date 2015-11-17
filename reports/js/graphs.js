	//var data = projects[project];
	//console.log(project);
	//console.log(data);	// returned object in screenshot
	
	// workaround because for loop doesnt work. 
	// hardcoded values for now because regardless of I it will just pick last value in array.
	var keys = Object.keys(projects);
	var i = 0;

for (key in keys) { 
	console.log(keys[key]);
	createCharts(keys[key]);
}

function createCharts (obj) {

	//Regular pie chart example
	nv.addGraph(function() {
	  var chart = nv.models.pieChart()
	      .x(function(d) { return d.label })
	      .y(function(d) { return d.value })
	      .showLabels(true);
	
		var selectorStr = "#" + obj + "cc" + " svg";
		console.log("Selector: :" + selectorStr);
	    d3.select(selectorStr)
	        .datum(projects[obj].cc)
	        .transition().duration(350)
	        .call(chart)
		    .style({ 'width': '300px', 'height': '300px' });
	        
	 	nv.utils.windowResize(chart.update);
	
	  return chart;
	});
	
	//Regular pie chart example
	nv.addGraph(function() {
	  var chart = nv.models.pieChart()
	      .x(function(d) { return d.label })
	      .y(function(d) { return d.value })
	      .showLabels(true);
	      
	      //.width(300)
	      //.height(300);
	
		var selectorStr = "#" + obj + "loc" + " svg";
		console.log("Selector: :" + selectorStr);
	    d3.select(selectorStr)
	        .datum(projects[obj].loc)
	        .transition().duration(350)
	        .call(chart);
	    
	    
	    //    .style({ 'width': '300px', 'height': '300px' });
	
	  nv.utils.windowResize(chart.update);
		
	  return chart;
	});
	
}
	
	
function first(obj) {
	for (var a in obj) return a;
}
