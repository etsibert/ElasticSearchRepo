#ElasticSearch R Integration
library(RJSONIO)
library(httr)
library(dplyr)
library(zoo)

JSONConv<-function(e){
  data<-list(list(sensor=e$sensor, eventTime=e$time, dataCat=e$category, value=e$value, info=e$classification))
  return(data)
}

#Get all events accross all months for a single sensor: TempSensor001
eSearchUrl<-"http://localhost:9200/myevents/_search?size=1000"
Q<-'{
"query": {
"bool": {
"must": [
{"match": {"_index": "events_feb2016"}},
{"match": {"sensor": "TempSensor003"}}
]
}
}
}'
result<-VERB("GET", eSearchUrl, body=Q, content_type_json())
content(result)$hits$total  #Number of Records
data<-sapply(content(result)$hits$hits, FUN=function(x){ JSONConv(x$`_source`)})
df<-as.data.frame(t(sapply(data, rbind)))
names(df)<-c("Sensor","Time","Measurement","Value","Info")
df$Time<-strptime(df$Time, format="%Y-%m-%dT%H:%M:%S")
df$Value<-as.numeric(df$Value)
View(df)
plot(zoo(df$Value,order.by = df$Time), main="TempSensor003 Time Series (3 months)", xlab="Time", ylab="Temp")

