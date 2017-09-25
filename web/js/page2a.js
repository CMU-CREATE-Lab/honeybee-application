/**
 * Helper functions and callbacks for page2a.
 * @namespace Page2A
 */

var Page2A = {

  networks_list: [],
  html_button_scan: null,
  html_networks_ul: null,
  isScanning: false,


  /**
   * Called after the page container shows the page.
   */
  initialize: function() {
    console.log("Page2A.initialize");
    this.html_button_scan = $("#networks-scan");
    this.html_networks_ul = $("#networks-list");

    this.html_button_scan.off("click");
    this.html_button_scan.on("click", Page2A.onClickScan);
    this.setScanning(false);
    this.notifyNetworkListChanged([]);
  },


  /**
   * Called when the list of WiFi networks changes.
   * @param {json[]} new_list - the list of scanned WiFi networks. JSON keys to include: "ssid", "security_type"
   */
  notifyNetworkListChanged: function(new_list) {
    this.networks_list = (new_list == null) ? [] : new_list;
    // TODO compare old/new and only add/remove what is necessary
    this.clearList();
    this.populateList();
  },


  /**
   * Callback for when the honeybee device successfully responds to our request to join a WiFi network.
   * @param {json} json - An object with keys "ssid", "security_type" defined.
   */
  onNetworkConnected: function(json) {
    if (!App.honeybee_device) {
      console.warn("Tried onConnected for Page2A but does not have a honeybee device; returning to connect device screen.");
      App.goToPage("page1a");
      return;
    }
    App.honeybee_device.network = json;
    App.goToPage("page2b");
  },


  /**
   * Onclick listener for the Scan button.
   */
  onClickScan: function() {
    console.log("onClickScan");
    Page2A.setScanning(true);
    ApplicationInterface.wifiScan();
  },


  /**
   * Onclick listener for the Add Network button.
   */
  onClickAddNetwork: function() {
    console.log("onClickAddNetwork");
    ApplicationInterface.addNetwork();
  },


  // helper funtions (for wifi)


  /**
   * Display/hide dialog that indiciates if we are currently scanning for WiFi networks; also update scan button text.
   * @param {boolean} isScanning - True displays the dialog, False hides it.
   */
  setScanning: function(isScanning) {
    this.isScanning = isScanning;
    if (isScanning) {
      $.mobile.loading( "show", {
        text: "Scanning WiFi Networks",
        textVisible: true,
        theme: "b",
      });
    } else {
      $.mobile.loading("hide");
    }
    this.html_button_scan.button("refresh");
  },


  // helper functions (for listview)


  /**
   * Clears the displayed HTML list of all WiFi Network items.
   */
  clearList: function() {
    this.html_networks_ul.empty();
    this.html_networks_ul.listview("refresh");
  },


  /**
   * Populates the displayed HTML list with all WiFi networks contained in networks_list.
   */
  populateList: function() {
    var createDeviceListItemFromJson = function(json) {
      var ssid = json["ssid"];
      return $("<a href=\"#\"><h4>"+ssid+"</h4></a>");
    };
    var constructCallbackWithJson = function(json) {
      var onClickDeviceListItem = function(json) {
        console.log("onClickDeviceListItem with json:");
        console.log(json);
        Page2A.setScanning(false);
        ApplicationInterface.joinNetwork(json["ssid"],json["security_type"]);
      };

      // construct callback which calls onClickDeviceListItem with json object
      return function() { return onClickDeviceListItem(json);} ;
    };

    // add from networks_list
    for(i=0;i<this.networks_list.length;i++) {
      // grab json object
      var json = this.networks_list[i];
      // create html elements
      var a = createDeviceListItemFromJson(json);
      var li = $("<li></li>").append(a);
      this.html_networks_ul.append(li);
      // add click listener
      a.on("click", constructCallbackWithJson(json));
    }
    this.html_networks_ul.listview("refresh");
  },

}
