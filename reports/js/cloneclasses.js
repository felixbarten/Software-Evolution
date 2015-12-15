

function getJsonFromUrl() {
  var query = location.search.substr(1);
  var result = {};
  query.split("&").forEach(function(part) {
    var item = part.split("=");
    result[item[0]] = decodeURIComponent(item[1]);
  });
  return result;
}


var query = getJsonFromUrl();

var classid = query["key"];


console.log(query);
var h2 = d3.select("#header").html("Clone class " + classid);

var locationdiv = d3.select("#classlocations");

var div = d3.select("#source");

d3.json("json/cloneclasses.json", function(error, data) { 
	var locations = "";
	for (d in data) {
		if (data[d].key == classid) {
			console.log(data[d].clones);
			for (clone in data[d].clones) {
				console.log(clone);

					var clonesrc = "";
					for (line in data[d].clones[clone].source) {
						clonesrc = clonesrc + data[d].clones[clone].source[line] + "</br>";
					}
					locations = locations + data[d].clones[clone].location + "</br>";
		
					div.append("div")
					.append("p")
					.append("pre")
					.html(clonesrc);
				
			}

			locationdiv
					.append("p")
					.append("pre")
					.html(locations);


		}
	}

});
