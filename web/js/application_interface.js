/**
 * Namespace for all calls to the platform's native SDK.
 * @namespace ApplicationInterface
 */

var ApplicationInterface = {

  schema: "schema://",


  /**
   * Turns on or off scanning for BLE devices.
   * @param {boolean} flag - True if scanning; False otherwise.
   */
  bleScan: function(flag) {
    this.sendMessageToApplication("bleScan", [String(flag)]);
  },


  /**
   * Connect BLE device from the list of devices.
   * @param {index} deviceId - The index of the device (from Page1A.devices_list) to which you are trying to connect.
   */
  connectDevice: function(deviceId) {
    this.sendMessageToApplication("connectDevice", [String(deviceId)]);
  },


  /**
   * Sends BLE message to request honeybee device info.
   */
  requestDeviceInfo: function() {
    this.sendMessageToApplication("requestDeviceInfo", []);
  },


  /**
   * Perform a scan of broadcasting WiFi networks.
   */
  wifiScan: function() {
    this.sendMessageToApplication("wifiScan", []);
  },


  /**
   * request UI dialog for manually adding a WiFi network.
   */
  addNetwork: function() {
    this.sendMessageToApplication("addNetwork", []);
  },


  /**
   * Join a WiFi network with SSID and security type; the application is responsible for requesting the password from the user when network is not open.
   * @param {string} ssid - The SSID of the WiFi network to which you are connecting.
   * @param {integer} securityType - 1=open, 2=wep, 3=wpa.
   */
  joinNetwork: function(ssid, securityType) {
    this.sendMessageToApplication("joinNetwork", [String(ssid), String(securityType)]);
  },


  /**
   * Sends BLE message to request the current network status from the honeybee device.
   */
  requestNetworkInfo: function() {
    this.sendMessageToApplication("requestNetworkInfo", []);
  },


  /**
   * Sends BLE message to request removing the current WiFi network assigned on the connected honeybee device.
   */
  removeNetwork: function() {
    this.sendMessageToApplication("removeNetwork", []);
  },


  /**
   * Sends BLE message to set the feed key for the connected honeybee device.
   */
  setFeedKey: function(isEnabled, feedKey) {
    this.sendMessageToApplication("setFeedKey", [String(isEnabled), String(feedKey)]);
  },


  /**
   * Display a dialog box with a given message.
   * @param {string} message - the message to be displayed.
   */
  displayDialog: function(message) {
    this.sendMessageToApplication("displayDialog", [String(message)]);
  },


  /**
   * Sends BLE message to clear the feed key for the connected honeybee device.
   */
  removeFeedKey: function() {
    this.sendMessageToApplication("removeFeedKey", []);
  },


  /**
   * Sends BLE message to request Feed Key from the honeybee.
   */
  requestFeedKey: function() {
    this.sendMessageToApplication("requestFeedKey", []);
  },


  /**
   * Sends a request to change the window location to a URL described by schema://domain/params with each element of params separated by a comma (,). It is up to the platform to override these requests and parse the messages.
   * @param {string} domain - The name of the function.
   * @param {string[]} params - An array of strings representing the function parameters.
   */
  sendMessageToApplication: function(domain, params) {
    // base URL uses default schema and the function name as domain
    var url = this.schema + domain + "/" ;
    // encode each parameter as a URI Component
    url += params.map(encodeURIComponent).join("/");

    console.log("about to change window.location to: " + url);
    window.location = url;
  },

}
