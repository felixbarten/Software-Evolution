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
		  chart.tooltip.contentGenerator(function(data) {
	      		var modifiedkey = data.data.clone1 + " lines: " + data.data.begin1 + "-" + data.data.end1 + "</br> and " + data.data.clone2 + " lines: " + data.data.begin2 + "-" + data.data.end2;
	      		return "<b> " + modifiedkey + "</b>" + "<p> " + data.data.value + "Lines of Code</p>";
	      });
	
	  d3.select('#barchart svg')
	      .datum(bardata)
	      .call(chart);
	
	  nv.utils.windowResize(chart.update);
	
	  return chart;
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

var svg = d3.select("#chord svg")
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
    return stripProjectName(name);
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

  var g = svg.selectAll("g.group")
      .data(chord.groups)
    .enter().append("svg:g")
      .attr("class", "group")
//      .on("mouseover", fade(.02))
//      .on("mouseout", fade(.80));
        .on("mouseover", mouseover)
        .on("mouseout", function (d) { d3.select("#tooltip").style("visibility", "hidden") });

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
      .text(function(d) { return nameByIndex[d.index]; });

  var chordPaths = svg.selectAll("path.chord")
      .data(chord.chords)
    .enter().append("svg:path")
      .attr("class", "chord")
      .style("stroke", function(d) { return d3.rgb(fill(d.source.index)).darker(); })
      .style("fill", function(d) { return fill(d.source.index); })
      .attr("d", d3.svg.chord().radius(r0));

// Returns an event handler for fading a given chord group.
function fade(opacity) {
  return function(d, i) {
    svg.selectAll("path.chord")
        .filter(function(d) { return d.source.index != i && d.target.index != i; })
      .transition()
        .style("stroke-opacity", opacity)
        .style("fill-opacity", opacity);
  };
}

function mouseover(d, i) {
  console.log(d);
  console.log(i);
            d3.select("#tooltip")
              .style("visibility", "visible")
              .html("<h2> hi</h2>")
              .style("top", function () { return (d3.event.pageY - 80)+"px"})
              .style("left", function () { return (d3.event.pageX - 130)+"px";})

    chordPaths.classed("fade", function(p) {
              return p.source.index != i
                  && p.target.index != i;
    });
  }

});


          function groupTip (d) {
            var guru = d.gname, q = d3.format("0d");

            switch (guru) {
              case "g1": return "Guru Nanak"; //+ " lived for 70 years";
                  break;
              case "g2": return "Guru Angad"; // + " lived for 48 years";
                  break;
              case "g3": return "Guru Amar Das"; // + " lived for 95 years";
                  break;
              case "g4": return "Guru Ram Das"; // + " lived for 47 years";
                  break;
              case "g5": return "Guru Arjun Dev"; // + " lived for 43 years";
                  break;
              case "g6": return "Guru Har Gobind"; // + " lived for 49 years";
                  break;
              case "g7": return "Guru Har Rai"; // + " lived for 31 years";
                  break;
              case "g8": return "Guru Har Krishan"; // + " lived for 8 years";
                  break;
              case "g9": return "Guru Tegh Bahadar"; // + " lived for 54 years";
                  break;
              case "g10": return "Guru Gobind Singh"; // + " lived for 42 years";
                  break;
              default : return d.gname;

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

var width = 960,
    height = 500;

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
var path = svg.append("svg:g").selectAll("path")
    .data(force.links())
  .enter().append("svg:path")
//    .attr("class", function(d) { return "link " + d.type; })
    .attr("class", "link")
    .attr("marker-end", "url(#end)");

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
    .text(function(d) { return d.name; });


// add the curvy lines
function tick() {
    path.attr("d", function(d) {
        var dx = d.target.x - d.source.x,
            dy = d.target.y - d.source.y,
            dr = Math.sqrt(dx * dx + dy * dy) + 100;
        return "M" + 
            d.source.x + "," + 
            d.source.y + "A" + 
            dr + "," + dr + " 0 0,1 " + 
            d.target.x + "," + 
            d.target.y;
    });

    node
        .attr("transform", function(d) { 
        return "translate(" + d.x + "," + d.y + ")"; });
}

});
