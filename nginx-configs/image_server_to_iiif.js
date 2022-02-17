var typeToDimensionMapping = {
  "v": "2560",
  "q": "1600",
  "w": "760",
  "r": "300",
  "t": "150",
  "f": "140",
  "b": "100"
}

function mapImageServerToIIIF(request, response) {
  // turn query string to hash
  var requestVars = request.variables['query_string'];
  var arrayOfKeyValues;

  if (requestVars) {
  	arrayOfKeyValues = requestVars.split('&');
  }
  
  var paramsHash = {};
  // Turns ['a=1', 'b=2', 'c=3'] and stores it into paramsHash as {"a": "1", "b": "2", "c": "3"}
  for (var i = 0; i < arrayOfKeyValues.length; i++) {
    paramsHash[arrayOfKeyValues[i].split('=')[0]] = arrayOfKeyValues[i].split('=')[1];
  }
  
  // Dimension Stuff
  var imageType = paramsHash['t'].toLowerCase();
  var dimension = typeToDimensionMapping[imageType];
  var urlSegment;
  var crop;
  var quality;
  if (imageType == 'tiff') {
    quality = "default.tif";
  } else {
    quality = "default.jpg";
  }
  
  if (imageType == 'g' || imageType == 'j' || imageType == 's' || imageType == 'tif') {
    urlSegment = "full";
  } else {
    urlSegment = "!" + dimension + "," + dimension;
  }
  var identitifier = paramsHash['id']
  if (paramsHash['t'] == 'b') {
    crop = "square";
  } else {
    crop = "full";
  }
  
  // TODO: Figure out how to include this an an environment variable and point to local iiif. -KAK 1/12/2022. 
  // For deployments ... ALWAYS MAKE SURE THIS IS THE ACTIVE LINE when pushing to QA or Prod.
  // var imageUrl = "http://0.0.0.0:8182/iiif/2/"+ identitifier + "/" + crop + "/" + urlSegment +"/0/" + quality
  /* For local development ... Test via: http://localhost:8080/index.php?id=anything&t=f
     This works for Macs. You may need to change this depending on your personal machine. For reference: https://forums.docker.com/t/how-to-reach-localhost-on-host-from-docker-container/113321/4
     If you have trouble, feel free to point this to http://172.16.1.195:8182/iiif/2/, which is the dev/qa IIIF. */
  var imageUrl = "http://172.17.0.1:8182/iiif/2/" + identitifier + "/" + crop + "/" + urlSegment + "/0/" + quality
  return imageUrl ; 
}
