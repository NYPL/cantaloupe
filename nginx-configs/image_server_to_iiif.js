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
  var arrayOfKeyValues = request.variables['query_string'].split('&');
  var paramsHash = {};


  request.remoteAddress 


  // Turns ['a=1', 'b=2', 'c=3'] and stores it into paramsHash as {"a": "1", "b": "2", "c": "3"}
  for (var i = 0; i < arrayOfKeyValues.length; i++) {
    paramsHash[arrayOfKeyValues[i].split('=')[0]] = arrayOfKeyValues[i].split('=')[1];
  }

  // Dimension Stuff
  var imageType = paramsHash['t'].toLowerCase();
  var dimension = typeToDimensionMapping[imageType];
  var urlSegment;
  var crop;

  if (imageType == 'u' || imageType == 'j' || imageType == 's') {
    urlSegment = "full";
  } else {
    urlSegment = "!" + dimension + "," + dimension;
  }
  var identitifier = paramsHash['id']

  if (paramsHash['t'] == 'b') {
    crop = "square"
  } else {
    crop = "full"
  }

  var imageUrl = "http://0.0.0.0:8182/iiif/2/"+ identitifier + "/" + crop + "/" + urlSegment +"/0/default.jpg"
  
  if (paramsHash['t'] == 'u' || paramsHash['t'] == 'j' || paramsHash['t'] == 's') {
    request.headersOut['X-Ufile'] = 'true';
    return imageUrl + "?ufile=true";
  }  else {
    return imageUrl;
  }
}

