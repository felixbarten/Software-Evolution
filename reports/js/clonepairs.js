

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

var clonename = query["clone"];


console.log(query);
var h2 = d3.select("#header").html("Code Clones in: " + clonename);

var div = d3.select("#source");

d3.json("json/codeclones.json", function(error, data) { 
	for (d in data) {
		if (data[d].clone == clonename) {
			for (clone in data[d].clones) {
				console.log(clone);

					var clonesrc = "";
					for (line in data[d].clones[clone]) {
						clonesrc = clonesrc + data[d].clones[clone][line] + "</br>";
					}

					div.append("div")
					.append("p")
					.append("pre")
					.html(clonesrc);
				
			}




		}
	}

});
