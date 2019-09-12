component hint="GeoIP2 API Service" output="false" {

	function getSettings() provider="coldbox:setting:maxmind" {}

	struct function lookup(required string ip, string api="insights"){
		var response = {}
		http url="#getSettings().server#/#arguments.api#/#arguments.ip#" method="get" username="#getSettings().userID#" password="#getSettings().key#" result="response" {}

		return parseResponse(response);
	}

	private function parseResponse(required struct response) {

		try {
			var result = deserializeJSON(response.filecontent)
		} catch (any local.e){
			result = [
				 "country":["names":["en":"Unknown"]]
				,"error":"Unable to parse response"
			]
		}
		
		if (response.status_code != 200){
			result = [
				 "country":["names":["en":"Unknown"]]
				,"error":result.error
			]
		}

		return new Response(result);
	}
}