	//var data = projects[project];
	//console.log(project);
	//console.log(data);	// returned object in screenshot
	
	// workaround because for loop doesnt work. 
	// hardcoded values for now because regardless of I it will just pick last value in array.
	var keys = Object.keys(projects);
	var i = 0;


	//Regular pie chart example
	nv.addGraph(function() {
	  var chart = nv.models.discreteBarChart()
	      .x(function(d) { return d.label })    //Specify the data accessors.
	      .y(function(d) { return d.value })
	      .staggerLabels(true)    //Too many bars and not enough room? Try staggering labels.
	      .showValues(false)       //...instead, show the bar value right on top of each bar.
	      .showXAxis(false);
	      
	      //chart.interactiveLayer.enabled(true);
		  chart.tooltip.enabled(true);        //Don't show tooltips
		  chart.tooltip.gravity("n");
		  chart.tooltip.position({"top": 200, "left": 500});
		  chart.tooltip.contentGenerator(function(data) {
	      		var modifiedkey = data.data.clone1 + " lines" + data.data.begin1 + "-" + data.data.end1 + " and " + data.data.clone2 + " lines:" + data.data.begin2 + "-" + data.data.end2;
	      		return "<h3> " + modifiedkey + "</h3>" + "<p> " + data.data.value + "Lines of Code</p>";
	      });
	
	  d3.select('#barchart svg')
	      .datum(bardata)
	      .call(chart);
	
	  nv.utils.windowResize(chart.update);
	
	  return chart;
	});
	


/*

  chart.tooltipContent(function(key, x, y, e, graph) {
      return '<h3>' + e.series.key  + gettext(' Errors') + '</h3>' +
      '<p>' +  y + gettext(' Errors on ')  + e.point.date + ' </p>'
  });

  */