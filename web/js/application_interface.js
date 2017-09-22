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


  wifiScan: function() {
    this.sendMessageToApplication("wifiScan", []);
  },


  addNetwork: function() {
    this.sendMessageToApplication("addNetwork", []);
  },


  joinNetwork: function(ssid, securityType) {
    this.sendMessageToApplication("joinNetwork", [String(ssid), String(securityType)]);
  },


  requestNetworkInfo: function() {
    this.sendMessageToApplication("requestNetworkInfo", []);
  },


  removeNetwork: function() {
    this.sendMessageToApplication("removeNetwork", []);
  },


  setFeedKey: function(isEnabled, feedKey) {
    this.sendMessageToApplication("setFeedKey", [String(isEnabled), String(feedKey)]);
  },


  displayDialog: function(message) {
    this.sendMessageToApplication("displayDialog", [String(message)]);
  },


  removeFeedKey: function() {
    this.sendMessageToApplication("removeFeedKey", []);
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
