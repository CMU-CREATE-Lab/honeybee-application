var Page2A = {

  networks_list: [],
  html_button_scan: null,
  html_networks_ul: null,
  isScanning: false,


  initialize: function() {
    console.log("Page2A.initialize");
    this.html_button_scan = $("#networks-scan");
    this.html_networks_ul = $("#networks-list");

    this.html_button_scan.off("click");
    this.html_button_scan.on("click", Page2A.onClickScan);
    this.setScanning(false);
    this.notifyNetworkListChanged([]);
  },


  notifyNetworkListChanged: function(new_list) {
    this.networks_list = (new_list == null) ? [] : new_list;
    // TODO compare old/new and only add/remove what is necessary
    this.clearList();
    this.populateList();
  },


  onClickScan: function() {
    console.log("onClickScan");
    Page2A.setScanning(!Page2A.isScanning);
    // TODO callback to application
  },


  // helper funtions (for wifi)


  onConnected: function(json) {
    if (!App.honeybee_device) {
      console.warn("Tried onConnected for Page2A but does not have a honeybee device; returning to connect device screen.");
      App.goToPage("page1a");
      return;
    }
    App.honeybee_device.network = json;
    App.goToPage("page2b");
  },


  setScanning: function(isScanning) {
    this.isScanning = isScanning;
    if (isScanning) {
      $.mobile.loading( "show", {
        text: "Scanning WiFi Networks",
        textVisible: true,
        theme: "b",
      });
      this.html_button_scan.val("Stop Scanning");
    } else {
      $.mobile.loading("hide");
      this.html_button_scan.val("Scan");
    }
    this.html_button_scan.button("refresh");
  },


  // helper functions (for listview)


  clearList: function() {
    this.html_networks_ul.empty();
    this.html_networks_ul.listview("refresh");
  },


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
        // TODO callback to application
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
