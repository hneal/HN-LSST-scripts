awk '/Reb.\/Temp.\/limitHi/{print $1,$2,"25.0"}{print $0}' FocalPlane-operational-Nov5.properties > FocalPlane-operational-Nov5-RebTempHi25.properties
