( import "../common/service.jsonnet" ) {
  // global variables
  _kafkaprefix:: "tbd",

  // override super global variables
  _mname: "kafka",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "brokerport:9092",
    "jmxport:9999"
  ]
}
