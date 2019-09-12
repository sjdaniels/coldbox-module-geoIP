component hint="GeoIP plugin" output="false" cache="true" cachetimeout="0" {

	function init(){
		///////////////////////////////////////////////////////////////////////////////////////////////////
		//			 				GEOIP (IP LOCATION PROVIDER) SETTINGS
		///////////////////////////////////////////////////////////////////////////////////////////////////
		var libs = getDirectoryFromPath(getCurrentTemplatePath())
		libs = listDeleteAt(libs,listlen(libs,"/"),"/")
		libs &= "/lib"

		// for GeoIP integration
		//use / (forward slash) since we are passing this to Java (City, Country, Lat, Lon)
		GeoIPCityDB="#libs#/GeoLiteCity.dat"; 
		geoLib = "#libs#/geoIP.jar";
			
		GeoIPCity  = createobject("java","com.maxmind.geoip.LookupService",geoLib).init(GeoIPCityDB,'LookupService.GEOIP_MEMORY_CACHE');
		GeoIPRegion = createobject("java","com.maxmind.geoip.regionName",geoLib).init();
		//set the City version so we can see what version is loaed
		GeoIPCityDbVersion=GeoIPCity.getDatabaseInfo().getDate().toString();
		GeoIPRegion  = createobject("java","com.maxmind.geoip.regionName",geoLib).init();
		return this;
	}

	function lookup(required string IP){
		// I had to create a query to match it with an existing format i was already using
		// I needed to match the same column names so I pull in the data and then build a query
		var getlocation = querynew('COUNTRYLONG,COUNTRYSHORT,IPCITY,IPISP,IPLATITUDE,IPLONGITUDE,IPREGION,IPREGIONSHORT,POSTALCODE,DMACODE,AREACODE,CITYDBVER,ISPDBVER');
		var loc=GeoIPCity.getLocation(IP);
		var region=GeoIPRegion;
		var regionName='';
		//ISP database is not used in this example but is easily added
		//var isp=Application.GeoIPISP.getOrg(IP);
		
		/*
		We recieve the region code in order to translate it into the name we use region.resionNameByCode()
		
		*/
		
		if (isdefined('loc.countryCode') AND isdefined('loc.region'))
			regionName=region.regionNameByCode(loc.countryCode, loc.region);

		QueryAddRow(getlocation, 1);
		if (isdefined('loc.countryName'))
			QuerySetCell(getlocation, "COUNTRYLONG", loc.countryName, 1);
		if (isdefined('loc.countryCode'))
			QuerySetCell(getlocation, "COUNTRYSHORT", loc.countryCode, 1);
		if (isdefined('loc.city'))
			QuerySetCell(getlocation, "IPCITY", loc.city, 1);
		if (isdefined('loc.latitude'))
			{
			QuerySetCell(getlocation, "IPLATITUDE", loc.latitude, 1);
			QuerySetCell(getlocation, "IPLONGITUDE", loc.longitude, 1);
			}
		if (isdefined('regionName'))
			QuerySetCell(getlocation, "IPREGION", regionName, 1);
		if (isdefined('loc.region'))
			QuerySetCell(getlocation, "IPREGIONSHORT", loc.region, 1);
		if (isdefined('loc.postalCode'))
			QuerySetCell(getlocation, "POSTALCODE", loc.postalCode, 1); 
		if (isdefined('loc.dma_code'))
			QuerySetCell(getlocation, "DMACODE", loc.dma_code, 1);
		if (isdefined('loc.area_code'))
			QuerySetCell(getlocation, "AREACODE", loc.area_code, 1);
		QuerySetCell(getlocation, "CITYDBVER", GeoIPCityDbVersion, 1);

		return getLocation;
	}

	string function lookupAsString(required string IP) {
		var result = ["Unknown"];
		var q = lookup(arguments.IP);

		if (q.recordcount) {
			result = [];
			if (q.ipcity.len())
				result.append(q.ipcity)
			if (q.ipregion.len())
				result.append(q.ipregion)
			if (q.countrylong.len())
				result.append(q.countrylong)
		}
	
		return result.toList(", ");
	}

}