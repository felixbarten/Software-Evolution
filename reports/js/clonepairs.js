

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
var clonepairid = query["clonepairid"];

//var locations = "";

console.log("query obj: " + query);



var h2 = d3.select("#header");

var locationdiv = d3.select("#pairlocations");

var div = d3.select("#source");

if (clonename != undefined) {
	console.log("Name mode");
	h2.html("Code Clones in: " + clonename);
	d3.json("json/codeclones.json", function(error, data) { 
		for (d in data) {
			if (data[d].clone == clonename) {
				var dataobj = data[d]
				for (clone in data[d].clones) {
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
} else if (clonepairid != undefined) {
	console.log("ID based mode");
	h2.html("Clone Pair with ID: " + clonepairid);
	d3.json("json/clonepairs2.json", function(error, data2) { 
		var locations = "";
		var clonesrc = "";
		console.log(error);
		console.log(data2);
		for (d in data2) {
			if (data2[d].clonepairid == clonepairid) {
				var dataobj = data2[d]

				console.log("match found!");
				console.log(dataobj);
				for (srcarr in dataobj.source) {
					for (linenr in dataobj.source[srcarr]) {
						clonesrc = clonesrc + dataobj.source[srcarr][linenr] + "</br>";

					}

					locations = "" + dataobj.clone1fullloc + "</br>" + dataobj.clone2fullloc + "</br>";
					console.log(locations);
		
					div.append("div")
					.append("p")
					.append("pre")
					.html(clonesrc);
					clonesrc = "";
				}




			}
		}
			locationdiv
					.append("p")
					.append("pre")
					.html(locations);
	});
} else {
	console.log("No data :(");
					div.append("div")
						.append("p")
						.append("pre")
						.html("No Data");
}


