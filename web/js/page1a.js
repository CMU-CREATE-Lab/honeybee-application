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
    // TODO app callback
  },


  // helper functions (for listview)


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


  clearList: function() {
    this.html_devices_ul.empty();
    this.html_devices_ul.listview("refresh");
  },


  populateList: function() {
    var createDeviceListItemFromJson = function(json) {
      var name = json["name"];
      var mac = json["mac_address"];
      return "<li><a href=\"#\"><h4>"+name+"</h4><p>"+mac+"</p></a></li>";
    };

    // add from devices_list
    for(i=0;i<this.devices_list.length;i++) {
      // TODO handle click listeners?
      this.html_devices_ul.append(createDeviceListItemFromJson(this.devices_list[i]));
    }
    this.html_devices_ul.listview("refresh");
  },

}
