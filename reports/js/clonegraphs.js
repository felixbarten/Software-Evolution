function stripProjectName(name) {
    var origname = name;
    if (name.substring(0,8) == "smallsql") {
      name = name.substring(8, name.length);
    }
    if (name.substring(0,8) == "JavaTest") {
      name = name.substring(8, name.length);
    }
    if (name.substring(0,9) == "JavaTest2") {
      name = name.substring(9, name.length);

    }
    if (name.substring(0,6) == "hsqldb") {
      name = name.substring(6, name.length);
    }

    if (origname != name) {
        name = ".." + name;    
    }
    return name;

}
  var barfill = d3.scale.category20();

var colorbrewerscale = d3.scale.ordinal()
.range(["rgb(255,255,178)", "rgb(254,204,92)", "rgb(253,141,60)", "rgb(240,59,32)", "rgb(189,0,38)"]);

// range 
/*
 <svg width="15" height="75">
  <rect fill="rgb(255,255,178)" width="15" height="15" y="0"></rect>
  <rect fill="rgb(254,204,92)" width="15" height="15" y="15"></rect>
  <rect fill="rgb(253,141,60)" width="15" height="15" y="30"></rect><
  rect fill="rgb(240,59,32)" width="15" height="15" y="45"></rect>
  <rect fill="rgb(189,0,38)" width="15" height="15" y="60"></rect></svg>
*/
  //var data = projects[project];
	//console.log(project);
	//console.log(data);	// returned object in screenshot
	
	// workaround because for loop doesnt work. 
	// hardcoded values for now because regardless of I it will just pick last value in array.
	var keys = Object.keys(projects);
	var i = 0;

/*
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
      chart.tooltip.fixedTop(50);
      chart.tooltip.gravity("n");

		  chart.tooltip.contentGenerator(function(data) {
        console.log(data);
	      		var modifiedkey = data.data.clone1 + " lines: " + data.data.begin1 + "-" + data.data.end1 + "</br> and " + data.data.clone2 + " lines: " + data.data.begin2 + "-" + data.data.end2;
	      		return "<b> " + modifiedkey + "</b>" + "<p> " + data.data.value + "Lines of Code</p>";
	      });
	
	  d3.select('#barchart svg')
	      .datum(bardata)
	      .call(chart);
	
	  nv.utils.windowResize(chart.update);
	
	  return chart;
	});
*/
// bar chart

var margin = {top: 40, right: 20, bottom: 30, left: 40},
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

var formatPercent = d3.format(".0%");

var x = d3.scale.category20()
    .rangeRoundBands([0, width], .1);


var colorbrewerscale = d3.scale.ordinal()
    .domain(x.domain())
    .range(colorbrewer.RdBu[9]);

/*
var colorbrewerscale = d3.scale.ordinal()
.range(["rgb(255,255,178)", "rgb(254,204,92)", "rgb(253,141,60)", "rgb(240,59,32)", "rgb(189,0,38)"]);
*/
var y = d3.scale.linear()
    .range([height, 0]);

var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");

var tip = d3.tip()
  .attr('class', 'd3-tip')
  .offset([-10, 0])
  .html(function(d) {
    var modifiedkey = d.clone1 + " lines: " + d.begin1 + "-" + d.end1 + "</br> and " + d.clone2 + " lines: " + d.begin2 + "-" + d.end2;
    return "<strong>" + modifiedkey + ":</strong> <span style='color:red'>Size: "+ d.value + "</span>";
  })

var barpairsvg = d3.select("#bargraph")
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

barpairsvg.call(tip);

d3.json("json/bargraph.json", function(error, data) {
  x.domain(data.map(function(d) { return d.label; }));
  y.domain([0, d3.max(data, function(d) { return d.value; })]);

  barpairsvg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .text("Clone Pairs")
      .call(xAxis);

  barpairsvg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("LOC");

  barpairsvg.selectAll(".bar")
      .data(data)
    .enter().append("rect")
      .attr("class", "bar")
      .attr("x", function(d) { return x(d.label); })
      .attr("width", x.rangeBand())
      .attr("y", function(d) { return y(d.value); })
      .attr("height", function(d) { return height - y(d.value); })
      .attr("fill", function(d) { return barfill(d.value); })
      .on('mouseover', tip.show)
      .on('mouseout', tip.hide)
      .on('click', onClickBar())

});

function onClickBar() {
  return function(d) {
    console.log(d);
    //  TODO ADD SOME WAY OF IDENTIFYING THE VARIOUS CLONE PAIRS WITH A SHARED IDENTFIER? MAYBE JUST ITERATE OVER THEM THE SAME WAY AND get same ID. 

    window.location = "clonepairs?clonepairid=" + d.clonepairid;
  }
}

function type(d) {
  d.value = +d.value;
  return d;
}

// bar CLASS graph 
// bar chart

var margin = {top: 40, right: 20, bottom: 30, left: 40},
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

var formatPercent = d3.format(".0%");

var x = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1);

var y = d3.scale.linear()
    .range([height, 0]);

var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");

var classtip = d3.tip()
  .attr('class', 'd3-tip')
  .offset([-10, 0])
  .html(function(d) {
    return "<strong>" + d.clones + ":</strong> <span style='color:red'>Size: "+ d.value + "</span>";
  })

var barclasssvg = d3.select("#barclassgraph")
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

barclasssvg.call(classtip);

d3.json("json/cloneclassbargraph.json", function(error, data) {
  x.domain(data.map(function(d) { return d.key; }));
  y.domain([0, d3.max(data, function(d) { return d.value; })]);

  barclasssvg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .text("Clone Pairs")
      .call(xAxis);

  barclasssvg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Number of fragments");

  barclasssvg.selectAll(".bar")
      .data(data)
    .enter().append("rect")
      .attr("class", "bar")
      .attr("x", function(d) { return x(d.key); })
      .attr("width", x.rangeBand())
      .attr("y", function(d) { return y(d.value); })
      .attr("height", function(d) { return height - y(d.value); })
      .attr("fill", function(d) { return barfill(d.value); })
      .on('mouseover', classtip.show)
      .on('mouseout', classtip.hide)
      .on('click', function(d) {     console.log(d);
    window.location = "cloneclasses.html?key=" + d.key; })
 
});

// bar CLASS LOC GRAPH

var margin = {top: 40, right: 20, bottom: 30, left: 40},
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

var formatPercent = d3.format(".0%");

var x = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1);

var y = d3.scale.linear()
    .range([height, 0]);

var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");

var classloctip = d3.tip()
  .attr('class', 'd3-tip')
  .offset([-10, 0])
  .html(function(d) {
    return "<strong>" + d.clones + ":</strong> <span style='color:red'>Size: "+ d.value + "</span>";
  })

var barclasslocsvg = d3.select("#barclasslocgraph")
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

barclasslocsvg.call(classloctip);

d3.json("json/cloneclasslocbargraph.json", function(error, data) {
  x.domain(data.map(function(d) { return d.key; }));
  y.domain([0, d3.max(data, function(d) { return d.value; })]);

  barclasslocsvg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .text("Clone Pairs")
      .call(xAxis);

  barclasslocsvg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("LOC");

  barclasslocsvg.selectAll(".bar")
      .data(data)
    .enter().append("rect")
      .attr("class", "bar")
      .attr("x", function(d) { return x(d.key); })
      .attr("width", x.rangeBand())
      .attr("y", function(d) { return y(d.value); })
      .attr("height", function(d) { return height - y(d.value); })
      .attr("fill", function(d) { return barfill(d.value); })
      .on('mouseover', classloctip.show)
      .on('mouseout', classloctip.hide)
      .on('click', onClickBarGraphClassLoc())
   
});

function onClickBarGraphClassLoc() {
  return function(d) {
    console.log(d);
    window.location = "cloneclasses.html?key=" + d.key;

  }
}

// grouped bar chart 

// width = 960 - 40 - 20 = 900
// height = 500 - 20 - 30 = 450
var margin = { top: 20, right: 20, bottom: 30, left: 40 },
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

var x0 = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1);

//  Constructs a new ordinal scale with an empty domain and an empty range.
//  The ordinal scale is invalid (always returning undefined) until an output range is specified).
var x1 = d3.scale.ordinal();

var y = d3.scale.linear()
    .range([height, 0]);

var color = d3.scale.ordinal()
    .range(["#097054", "#6599FF", "#FFDE00", "#FF9900"]);

//  Set up the xAxis to use our x0 scale and be oriented on the bottom.
var xAxis = d3.svg.axis()
    .scale(x0)
    .orient("bottom");
    // We don't worry about tickFormat here, as the ticks will be determined by the data.
var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");
//    .tickFormat(d3.format(".2s"));

// Set up the svg canvas with the width and height we calculated earlier.
var groupsvg = d3.select("#groupedbargraph").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
// Move it to the right margin.left pixels, and move it down margin.top pixels


// Our JSON looks like:
//               [{ "YEAR": 2012, "MONTH": 1,  "MMM": "JAN", "Total": 36, "Completed": 21, "Canceled": 10,  "Aborted": 5 },
//                { "YEAR": 2012, "MONTH": 2,  "MMM": "FEB", "Total": 60, "Completed": 30, "Canceled": 21, "Aborted": 9 }]

//                data = d3.nest()
//                    .key(function (d) { return d.MMM + " " + d.YEAR; })
//                    .entries(json_data)

d3.json("json/groupedbarchart.json", function(error, data) { 

/*
  {
    "label": "/Users/felixbarten/Git/Software-Evolution/smallsql0.21_src/src/smallsql/database/ExpressionFunctionTruncate.java5060 + /Users/felixbarten/Git/Software-Evolution/smallsql0.21_src/src/smallsql/database/ExpressionFunctionRound.java5060",
    "value": 10,
    "begin1": 50,
    "end1": 60,
    "begin2": 50,
    "end2": 60,
    "clonepairid": 2,
    "clonetype": 1,
    "clone1": "smallsql/database/ExpressionFunctionTruncate.java",
    "clone2": "smallsql/database/ExpressionFunctionRound.java"
  },
*/

// seriesNames = "Total", "Completed", "Canceled" and "Aborted"               See, we're filtering out "YEAR", "MONTH" and "MMM"



//var seriesNames = d3.keys(data[0]).filter(function (key) { return (key !== "label") && (key !== "value") && (key !== "begin1")&& (key !== "begin2")&& (key !== "end1")&& (key !== "end2")&& (key !== "clone1")&& (key !== "clone2")&& (key !== "clonepairid"); });

var seriesNames = ["Type 1", "Type 2", "Type 3"]

//                alert(JSON.stringify(seriesNames));
//                alert(seriesNames);

data.forEach(function (d) {
    d.Flights = seriesNames.map(function (name) { 
    var typ = d.clonetype;
    var map  =   { 
      name: name, 
     value: 0
    }; 
    if (typ == 1 && map["name"] == "Type 1") {
      map["value"]  = +d["value"] 

    } else if (typ == 2 && map["name"] == "Type 2") {
      map["value"]  = +d["value"] 

    } else if (typ == 3 && map["name"] == "Type 3") {
      map["value"]  = +d["value"] 
    }
    console.log(map);
    return map;


  });
    console.log(d.Flights);
    //alert("hi --- " + JSON.stringify(d.Flights));
});

//alert(JSON.stringify(data));

//x0.domain(data.map(function (d) { return d.State; }));
// Change State to be MMM, YEAR (for example: "Jan 2012") Could change this to Jan '12
x0.domain(data.map(function (d) { return d.clonepairid }));
//alert(JSON.stringify(data.map(function (d) { return d.MMM + " " + d.YEAR; })));

//                //x1.domain(seriesNames).rangeRoundBands([0, x0.rangeBand()]);
x1.domain(seriesNames).rangeRoundBands([0, x0.rangeBand()]);

//                //y.domain([0, d3.max(data, function (d) { return d3.max(d.ages, function (d) { return d.value; }); })]);
//                // Make the y domain go from 0 up to the max of d.Total (Total flights)
//                y.domain([0, d3.max(data, function (d) { return d3.max(d.Total); })]);
y.domain([0, (10 + d3.max(data, function (d) { return d3.max(d.Flights, function (d) { return d.value; }); }))]);


// The axis business
groupsvg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis);

groupsvg.append("g")
    .attr("class", "y axis")
    .call(yAxis)
.append("text")
    .attr("transform", "rotate(-90)")
    .attr("y", 6)
    .attr("dy", ".71em")
    .style("text-anchor", "end")
    .text("LOC of clone types");


var state = groupsvg.selectAll(".state")
    .data(data)
.enter().append("g")
    .attr("class", "g")
    .attr("transform", function (d) { return "translate(" + x0(d.clonepairid) + ",0)"; });

//alert(JSON.stringify(d.Flights[0]));
state.selectAll("rect")
    .data(function (d) { return d.Flights; })
.enter().append("rect")
    .attr("width", x1.rangeBand())
    .attr("x", function (d) { return x1(d.name); })
    .attr("y", function (d) { return y(d.value); })
    .attr("height", function (d) { return height - y(d.value); })
    .style("fill", function (d) { return color(d.name); })
    .on('click', function(d) { console.log(d);  });


var legend = groupsvg.selectAll(".legend")
    .data(seriesNames.slice().reverse())
.enter().append("g")
    .attr("class", "legend")
    .attr("transform", function (d, i) { return "translate(0," + i * 20 + ")"; });

legend.append("rect")
    .attr("x", width - 18)
    .attr("width", 18)
    .attr("height", 18)
    .style("fill", color);

legend.append("text")
    .attr("x", width - 24)
    .attr("y", 9)
    .attr("dy", ".35em")
    .style("text-anchor", "end")
    .text(function (d) { return d; })
    .on("click", function (d) {
        alert(d);
        console.log(d);
    });
});

// Chord graph 

var w = 1280,
    h = 800,
    r1 = h / 2,
    r0 = r1 - 80;

var fill = d3.scale.category20c();

var chord = d3.layout.chord()
    .padding(.04)
    .sortSubgroups(d3.descending)
    .sortChords(d3.descending);

var arc = d3.svg.arc()
    .innerRadius(r0)
    .outerRadius(r0 + 20);

var chsvg = d3.select("#chord svg")
    .attr("width", w)
    .attr("height", h)
    .append("svg:g")
    .attr("transform", "translate(" + w / 2 + "," + h / 2 + ")");

d3.json("json/chordgraph.json", function(imports) {
  var indexByName = {},
      nameByIndex = {},
      matrix = [],
      n = 0;

  self.names = [];

// JS hack to get shorter names.
  function name(name) {
    return name;
  }

  // Compute a unique index for each package name.
  imports.forEach(function(d) {
    d = name(d.name);
    if (!(d in indexByName)) {
      nameByIndex[n] = d;
      indexByName[d] = n++;
      names.push(d);
    }
  });

  // Construct a square matrix counting package imports.
  imports.forEach(function(d) {
    var source = indexByName[name(d.name)],
        row = matrix[source];
    if (!row) {
     row = matrix[source] = [];
     for (var i = -1; ++i < n;) row[i] = 0;
    }
    d.imports.forEach(function(d) { row[indexByName[name(d)]]++; });
  });

  chord.matrix(matrix);
  console.log(matrix);

  var g = chsvg.selectAll("g.group")
      .data(chord.groups)
    .enter().append("svg:g")
      .attr("class", "group")
      .on("mouseover", fade(.02))
      .on("mouseout", fade(.80))
      .on("click", drillDown());

  g.append("svg:path")
      .style("stroke", function(d) { return fill(d.index); })
      .style("fill", function(d) { return fill(d.index); })
      .attr("d", arc);

  g.append("svg:text")
      .each(function(d) { d.angle = (d.startAngle + d.endAngle) / 2; })
      .attr("dy", ".35em")
      .attr("text-anchor", function(d) { return d.angle > Math.PI ? "end" : null; })
      .attr("transform", function(d) {
        return "rotate(" + (d.angle * 180 / Math.PI - 90) + ")"
            + "translate(" + (r0 + 26) + ")"
            + (d.angle > Math.PI ? "rotate(180)" : "");
      })
      .text(function(d) { return stripProjectName(nameByIndex[d.index]); });

  chsvg.selectAll("path.chord")
      .data(chord.chords)
    .enter().append("svg:path")
      .attr("class", "chord")
      .style("stroke", function(d) { return d3.rgb(fill(d.source.index)).darker(); })
      .style("fill", function(d) { return fill(d.source.index); })
      .attr("d", d3.svg.chord().radius(r0));

});

// Returns an event handler for fading a given chord group.
function fade(opacity) {
  return function(d, i) {
    console.log(d);
    console.log(i);
    chsvg.selectAll("path.chord")
        .filter(function(d) { return d.source.index != i && d.target.index != i; })
      .transition()
        .style("stroke-opacity", opacity)
        .style("fill-opacity", opacity);
  };
}
function drillDown() {
  return function(d,i) {
    console.log(names[i]);
    window.location = "clonepairs.html?clone=" + names[i];
  }
}


// get the data
d3.json("json/forcegraph.json", function(error, links) {

var nodes = {};

// Compute the distinct nodes from the links.
links.forEach(function(link) {
    link.source = nodes[link.source] || 
        (nodes[link.source] = {name: link.source});
    link.target = nodes[link.target] || 
        (nodes[link.target] = {name: link.target});
    link.value = +link.value;
});

var width = 1140,
    height = 700;

var force = d3.layout.force()
    .nodes(d3.values(nodes))
    .links(links)
    .size([width, height])
    .linkDistance(200)
    .charge(-300)
    .on("tick", tick)
    .start();

var svg = d3.select("#forcegraph svg")
    .attr("width", width)
    .attr("height", height);


// add the links and the arrows
var link = svg.selectAll(".link")
      .data(force.links())
    .enter().append("line")
      .attr("class", "link")
      .style("stroke-width", function(d) { return Math.sqrt(d.value); });

// define the nodes
var node = svg.selectAll(".node")
    .data(force.nodes())
  .enter().append("g")
    .attr("class", "node")
    .call(force.drag);

// add the nodes
node.append("circle")
    .attr("r", 5);

// add the text 
node.append("text")
    .attr("x", 12)
    .attr("dy", ".35em")
    .attr("style", "font-size: 10px;")
    .text(function(d) { return stripProjectName(d.name); });


// add the curvy lines
function tick() {
    link.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });


    node
        .attr("transform", function(d) { 
        return "translate(" + d.x + "," + d.y + ")"; });
}

});
