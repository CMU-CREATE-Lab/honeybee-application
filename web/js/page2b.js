/**
 * Helper functions and callbacks for page2b.
 * @namespace Page2B
 */

var Page2B = {

  html_network_name: null,
  html_network_status: null,
  html_network_ip: null,
  html_network_mac: null,
  html_button_removenetwork: null,


  /**
   * Called after the page container shows the page.
   */
  initialize: function() {
    console.log("Page2B.initialize");
    this.html_network_name = $("#network-name");
    this.html_network_status = $("#network-status");
    this.html_network_ip = $("#network-ip");
    this.html_network_mac = $("#network-mac");
    this.html_button_removenetwork = $("#network-remove");

    this.html_button_removenetwork.off("click");
    this.html_button_removenetwork.on("click", Page2B.onClickRemoveNetwork);
    if (!App.honeybee_device) {
      console.warn("Went to Page2B but does not have a honeybee device; returning to connect page.");
      App.goToPage("page1a");
      return;
    }
    if (!App.honeybee_device.hasNetworkInfo) {
      App.displaySpinner(true, "Please Wait...");
      ApplicationInterface.requestNetworkInfo();
    }
    if (App.honeybee_device.network != null) this.displayNetworkInfo();
  },


  /**
   * Onclick listener for Remove Network button
   */
  onClickRemoveNetwork: function() {
    App.honeybee_device.hasNetworkInfo = false;
    ApplicationInterface.removeNetwork();
  },


  // helper functions


  /**
   * Populate App.honeybee_device with WiFi Network information; this is called after receiving a response from requesting Network info.
   * @param {string} name - SSID of the network
   * @param {string} status - Current status of the network connection (string messages as defined in the protocol)
   * @param {string} ip - The IP address assigned to the honeybee device
   * @param {string} mac - The MAC address of the honeybee device
   */
  populateNetworkInfo: function(name, status, ip, mac) {
    App.displaySpinner(false);
    if (!App.honeybee_device) {
      console.warn("called populateDeviceInfo but does not have a honeybee device; returning to connect page.");
      App.goToPage("page1a");
      return;
    }
    if (!App.honeybee_device.network) {
      console.warn("called populateDeviceInfo but does not have a network");
      App.honeybee_device.network = {};
    }
    // Merge the contents of two or more objects together into the first object. (http://api.jquery.com/jQuery.extend/)
    $.extend(App.honeybee_device, {hasNetworkInfo: true});
    $.extend(App.honeybee_device.network, {name: name, status: status, ip: ip, mac: mac});

    Page2B.displayNetworkInfo();
  },


  /**
   * Populate HTML with WiFi Network information.
   */
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
