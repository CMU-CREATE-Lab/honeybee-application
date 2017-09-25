/**
 * Helper functions and callbacks for page4.
 * @namespace Page4
 */

var Page4 = {

  // device (1b)
  html_device_name: null,
  html_device_hardware: null,
  html_device_firmware: null,
  html_device_serial_number: null,
  // wifi (2b)
  html_network_name: null,
  html_network_status: null,
  html_network_ip: null,
  html_network_mac: null,
  // esdr
  html_feed_name: null,
  html_feed_exposure: null,
  html_feed_key: null,
  // feed key
  html_button_feedkey: null,


  /**
   * Called after the page container shows the page.
   */
  initialize: function() {
    console.log("Page4.initialize");

    this.html_device_name = $("#page4-device-name");
    this.html_device_hardware = $("#page4-device-hw");
    this.html_device_firmware = $("#page4-device-fw");
    this.html_device_serial_number = $("#page4-device-serial");
    this.displayDeviceInfo();

    this.html_network_name = $("#page4-network-name");
    this.html_network_status = $("#page4-network-status");
    this.html_network_ip = $("#page4-network-ip");
    this.html_network_mac = $("#page4-network-mac");
    this.displayNetworkInfo();

    this.html_feed_name = $("#page4-feed-name");
    this.html_feed_exposure = $("#page4-feed-exposure");
    this.html_feed_key = $("#page4-feed-key");
    this.displayFeedInfo();

    this.html_button_feedkey = $("#button-feed-key-remove");
    this.html_button_feedkey.off("click");
    this.html_button_feedkey.on("click", Page4.onClickRemoveFeedKey);
  },


  /**
   * Onclick listeneer for the Remove Feed Key button.
   */
  onClickRemoveFeedKey: function() {
    console.log("onClickRemoveFeedKey");
    ApplicationInterface.removeFeedKey();
  },


  /**
   * Callback for when the honeybee device has successfully cleared its stored Feed key.
   */
  onFeedKeyRemoved: function() {
    App.honeybee_device.esdr_feed = {};
    delete App.honeybee_device.esdr_feed_name;
    delete App.honeybee_device.esdr_feed_exposure;
    delete App.honeybee_device.esdr_feed_key;
    Page4.displayFeedInfo();
  },


  // helper functions


  /**
   * Populate HTML with Honeybee Device information.
   */
  displayDeviceInfo: function() {
    if (!App.honeybee_device) {
      console.warn("called displayDeviceInfo on page4 but does not have a honeybee device");
      App.goToPage("page1a");
      return;
    }
    var name = !(App.honeybee_device.device_name) ? "--" : App.honeybee_device.device_name;
    var hw = !(App.honeybee_device.hardware_version) ? "--" : App.honeybee_device.hardware_version;
    var fw = !(App.honeybee_device.firmware_version) ? "--" : App.honeybee_device.firmware_version;
    var serial = !(App.honeybee_device.serial_number) ? "--" : App.honeybee_device.serial_number;

    this.html_device_name.text(name);
    this.html_device_hardware.text(hw);
    this.html_device_firmware.text(fw);
    this.html_device_serial_number.text(serial);
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


  /**
   * Populate HTML with ESDR Feed information.
   */
  displayFeedInfo: function() {
    var feedName = !(App.honeybee_device.esdr_feed_name) ? "--" : App.honeybee_device.esdr_feed_name;
    var feedExposure = !(App.honeybee_device.esdr_feed_exposure) ? "--" : App.honeybee_device.esdr_feed_exposure;
    var feedKey = !(App.honeybee_device.esdr_feed_key) ? "--" : App.honeybee_device.esdr_feed_key;

    this.html_feed_name.text(feedName);
    this.html_feed_exposure.text(feedExposure);
    this.html_feed_key.text(feedKey);
  }

}
