var Page1A = {

  devices_list: [],
  html_devices_ul: null,


  initialize: function() {
    console.log("Page1A.initialize");
    devices_list = [];
    html_devices_ul = $("#devices-list");
  },


  notifyDeviceListChanged: function(new_list) {
    devices_list = (new_list == null) ? [] : new_list;
    // TODO compare old/new and only add/remove what is necessary
    Page1A.clearList();
    Page1A.populateList();
  },


  // helper functions (for listview)


  clearList: function() {
    html_devices_ul.empty();
    html_devices_ul.listview("refresh");
  },


  populateList: function() {
    var createDeviceListItemFromJson = function(json) {
      var name = json["name"];
      var mac = json["mac_address"];
      return "<li><a href=\"#\"><h4>"+name+"</h4><p>"+mac+"</p></a></li>";
    };

    // add from devices_list
    for(i=0;i<devices_list.length;i++) {
      html_devices_ul.append(createDeviceListItemFromJson(devices_list[i]));
    }
    html_devices_ul.listview("refresh");
  },

}
