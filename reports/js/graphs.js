for (project in projects) {


	//Regular pie chart example
	nv.addGraph(function() {
	  var chart = nv.models.pieChart()
	      .x(function(d) { return d.label })
	      .y(function(d) { return d.value })
	      .showLabels(true);
	
	    d3.select("#ccchart svg")
	        .datum(project)
	        .transition().duration(350)
	        .call(chart);
	
	  return chart;
	});
	
	//Donut chart example
	nv.addGraph(function() {
	  var chart = nv.models.pieChart()
	      .x(function(d) { return d.label })
	      .y(function(d) { return d.value })
	      .showLabels(true)     //Display pie labels
	      .labelThreshold(.05)  //Configure the minimum slice size for labels to show up
	      .labelType("percent") //Configure what type of data to show in the label. Can be "key", "value" or "percent"
	      .donut(true)          //Turn on Donut mode. Makes pie chart look tasty!
	      .donutRatio(0.35)     //Configure how big you want the donut hole size to be.
	      ;
	
		//projectdata = project + "data";
	
	    d3.select("#chart2 svg")
	        .datum(projects[project])
	        .transition().duration(350)
	        .call(chart);
	
	  return chart;
	});

}
