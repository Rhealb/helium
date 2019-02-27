( import "../common/service.jsonnet" ) {
  // global variables
  _amahkafkaprefix:: "",

  // override super global variables
  _mname: "amahkafka",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "amahport:8084",
    
  ],
}
