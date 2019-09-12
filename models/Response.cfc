component {

	function init(required struct response) {
		variables.response = arguments.response;
	}

	string function getString( string lang="en" ){
		var geo = variables.response;
		var result = []
		
		if (!isnull(geo.error))
			return geo.error;

		if (!isnull(geo.country) && !isnull(geo.country.names))
			result.append(geo.country.names[arguments.lang]?:geo.country.names["en"])

		if (!isnull(geo.subdivisions)){
			loop array="#geo.subdivisions#" item="local.subdivision" {
				if (!isnull(local.subdivision.names))
					result.append(local.subdivision.names[arguments.lang]?:local.subdivision.names["en"])
			}
		}

		if (!isnull(geo.city) && !isnull(geo.city.names))
			result.append(geo.city.names[arguments.lang]?:geo.city.names["en"])


		if (!result.len())
			return "Unknown";

		return result.toList(": ");
	}	

	string function getCountry(){
		var geo = variables.response;
		var result = "Unknown";
		if (!isnull(geo.country) && !isnull(geo.country.names))
			result = geo.country.names["en"];

		return result;
	}

	any function getCountryGeoID(){
		var geo = variables.response;
		if (!isnull(geo.country) && !isnull(geo.country.geoname_id))
			var result = geo.country.geoname_id;

		return result?:nullValue();
	}

	any function getAdmin1GeoID(){
		var geo = variables.response;
		if (!isnull(geo.subdivisions) && geo.subdivisions.len() && !isnull(geo.subdivisions[1].geoname_id))
			var result = geo.subdivisions[1].geoname_id;

		return result?:nullValue();
	}

	boolean function isAnonymousProxy() {
		var traits = variables.response.traits ?: {};
		return variables.response.traits.is_anonymous_proxy?:false;
	}

	function getResponse() {
		return variables.response;
	}
}