/**
 * Helper functions and callbacks for page1a.
 * @namespace Page1A
 */

var Page1A = {

  devices_list: [],
  html_button_scan: null,
  html_devices_ul: null,
  isScanning: false,


  /**
   * Called after the page container shows the page.
   */
  initialize: function() {
    console.log("Page1A.initialize");
    this.html_button_scan = $("#devices-scan");
    this.html_devices_ul = $("#devices-list");

    this.html_button_scan.off("click");
    this.html_button_scan.on("click", Page1A.onClickScan);
    this.setScanning(false);
    this.notifyDeviceListChanged([]);
  },


  /**
   * Onclick listener for the Scan button.
   */
  onClickScan: function() {
    console.log("onClickScan");
    Page1A.setScanning(!Page1A.isScanning);
    ApplicationInterface.bleScan(Page1A.isScanning);
  },


  /**
   * Called when the list of honeybee devices changes.
   * @param {json[]} new_list - The list of scanned honeybee devices. JSON keys to include: "name", "mac_address"
   */
  notifyDeviceListChanged: function(new_list) {
    this.devices_list = (new_list == null) ? [] : new_list;
    // TODO compare old/new and only add/remove what is necessary
    this.clearList();
    this.populateList();
  },


  /**
   * Callback for when a honeybee device is connected.
   */
  onDeviceConnected: function(json) {
    App.honeybee_device = json;
    App.displaySpinner(false);
    App.goToPage("page1b");
  },


  // helper funtions (for ble)


  /**
   * Turn on/off BLE scanning.
   * @param {boolean} isScanning - True to start scanning for bluetooth devices; False to stop scanning.
   */
  setScanning: function(isScanning) {
    this.isScanning = isScanning;
    if (isScanning) {
      App.displaySpinner(true, "Scanning BLE Devices");
      this.html_button_scan.val("Stop Scanning");
    } else {
      App.displaySpinner(false);
      this.html_button_scan.val("Scan");
    }
    this.html_button_scan.button("refresh");
  },


  // helper functions (for listview)


  /**
   * Clears the displayed HTML list of all honeybee device items.
   */
  clearList: function() {
    this.html_devices_ul.empty();
    this.html_devices_ul.listview("refresh");
  },


  /**
   * Populates the displayed HTML list with all honeybee devices contained in devices_list.
   */
  populateList: function() {
    var createDeviceListItemFromJson = function(json) {
      var name = json["name"];
      var mac = json["mac_address"];
      return $("<a href=\"#\"><h4>"+name+"</h4><p>"+mac+"</p></a>");
    };
    var constructCallbackWithJson = function(json) {
      var onClickDeviceListItem = function(json) {
        console.log("onClickDeviceListItem with json:");
        console.log(json);
        Page1A.setScanning(false);
        App.displaySpinner(true, "Connecting...");
        ApplicationInterface.connectDevice(json["device_id"]);
      };

      // construct callback which calls onClickDeviceListItem with json object
      return function() { return onClickDeviceListItem(json);} ;
    };

    // add from devices_list
    for(i=0;i<this.devices_list.length;i++) {
      // grab json object
      var json = this.devices_list[i];
      // create html elements
      var a = createDeviceListItemFromJson(json);
      var li = $("<li></li>").append(a);
      this.html_devices_ul.append(li);
      // add click listener
      a.on("click", constructCallbackWithJson(json));
    }
    this.html_devices_ul.listview("refresh");
  },

}
