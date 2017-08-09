var Page1A = {

  devices_list: [],
  html_button_scan: null,
  html_devices_ul: null,
  isScanning: false,


  initialize: function() {
    console.log("Page1A.initialize");
    this.html_button_scan = $("#devices-scan");
    this.html_devices_ul = $("#devices-list");

    this.html_button_scan.off("click");
    this.html_button_scan.on("click", Page1A.onClickScan);
    this.setScanning(false);
    this.notifyDeviceListChanged([]);
  },


  notifyDeviceListChanged: function(new_list) {
    this.devices_list = (new_list == null) ? [] : new_list;
    // TODO compare old/new and only add/remove what is necessary
    this.clearList();
    this.populateList();
  },


  onClickScan: function() {
    console.log("onClickScan");
    Page1A.setScanning(!Page1A.isScanning);
    ApplicationInterface.bleScan(Page1A.isScanning);
  },


  // helper funtions (for ble)


  onConnected: function(json) {
    App.honeybee_device = json;
    App.goToPage("page1b");
  },


  setScanning: function(isScanning) {
    this.isScanning = isScanning;
    if (isScanning) {
      $.mobile.loading( "show", {
        text: "Scanning BLE Devices",
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
    this.html_devices_ul.empty();
    this.html_devices_ul.listview("refresh");
  },


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
        // TODO callback to application
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
