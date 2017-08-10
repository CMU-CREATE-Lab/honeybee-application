var ApplicationInterface = {

  schema: "schema://",


  bleScan: function(flag) {
    this.sendMessageToApplication("bleScan", [String(flag)]);
  },


  connectDevice: function(deviceId) {
    this.sendMessageToApplication("connectDevice", [String(deviceId)]);
  },


  requestDeviceInfo: function() {
    this.sendMessageToApplication("requestDeviceInfo", []);
  },


  wifiScan: function(flag) {
    this.sendMessageToApplication("wifiScan", [String(flag)]);
  },


  // ASSERT: domain is a string, params is an array of strings
  sendMessageToApplication: function(domain, params) {
    // base URL uses default schema and the function name as domain
    var url = this.schema + domain + "/" ;
    // encode each parameter as a URI Component
    url += params.map(encodeURIComponent).join("/");

    console.log("about to change window.location to: " + url);
    window.location = url;
  },

}
