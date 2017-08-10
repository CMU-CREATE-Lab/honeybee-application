var Page2B = {

  html_network_name: null,
  html_network_status: null,
  html_network_ip: null,
  html_network_mac: null,


  initialize: function() {
    console.log("Page2B.initialize");
    this.html_network_name = $("#network-name");
    this.html_network_status = $("#network-status");
    this.html_network_ip = $("#network-ip");
    this.html_network_mac = $("#network-mac");

    if (!App.honeybee_device) {
      console.warn("Went to Page2B but does not have a honeybee device; returning to connect page.");
      App.goToPage("page1a");
      return;
    }
    if (!App.honeybee_device.hasNetworkInfo) {
      ApplicationInterface.requestNetworkInfo();
    }
    this.displayNetworkInfo();
  },


  populateNetworkInfo: function(name, status, ip, mac) {
    if (!App.honeybee_device) {
      console.warn("called populateDeviceInfo but does not have a honeybee device; returning to connect page.");
      App.goToPage("page1a");
      return;
    }
    if (!App.honeybee_device.network) {
      console.warn("called populateDeviceInfo but does not have a network; returning to previous page.");
      App.goToPage("page2a");
      return;
    }
    // Merge the contents of two or more objects together into the first object. (http://api.jquery.com/jQuery.extend/)
    $.extend(App.honeybee_device, {hasNetworkInfo: true});
    $.extend(App.honeybee_device.network, {name: name, status: status, ip: ip, mac: mac});

    Page2B.displayNetworkInfo();
  },


  displayNetworkInfo: function() {
    var name = !(App.honeybee_device.network.name) ? "--" : App.honeybee_device.network.name;
    var status = !(App.honeybee_device.network.status) ? "--" : App.honeybee_device.network.status;
    var ip = !(App.honeybee_device.network.ip) ? "--" : App.honeybee_device.network.ip;
    var mac = !(App.honeybee_device.network.mac) ? "--" : App.honeybee_device.network.mac;

    this.html_network_name.text(name);
    this.html_network_status.text(status);
    this.html_network_ip.text(ip);
    this.html_network_mac.text(mac);
  },

}
