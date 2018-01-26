/**
 * Helper functions and callbacks for page1b.
 * @namespace Page1B
 */

var Page1B = {

  html_device_name: null,
  html_device_hardware: null,
  html_device_firmware: null,
  html_device_serial_number: null,
  html_device_feed_key: null,


  // TODO handle disconnect device by user navigation (otherwise we are connected to multiple devices with no control)


  /**
   * Called after the page container shows the page.
   */
  initialize: function() {
    console.log("Page1B.initialize");
    this.html_device_name = $("#device-name");
    this.html_device_hardware = $("#device-hw");
    this.html_device_firmware = $("#device-fw");
    this.html_device_serial_number = $("#device-serial");
    this.html_device_feed_key = $("#device-feedkey");

    if (!App.honeybee_device) {
      console.warn("Went to Page1B but does not have a honeybee device; returning to previous page.");
      App.goToPage("page1a");
      return;
    }
    if (!App.honeybee_device.hasDeviceInfo) {
      App.displaySpinner(true, "Requesting Device Information...");
      ApplicationInterface.requestDeviceInfo();
    }
    this.displayDeviceInfo();
    $("#request-feedkey").off("click");
    $("#request-feedkey").on("click", Page1B.onClickRequestFeedKey);
    this.displayFeedKey();
  },


  /**
   * Populate App.honeybee_device with honeybee device information; this is called after receiving a response from requesting device info.
   * @param {string} name - The honeybee device name
   * @param {string} hw - The hardware version of the honeybee device
   * @param {string} fw - The firmware version of the honeybee device
   * @param {string} serial - The serial number of the honeybee device
   */
  populateDeviceInfo: function(name, hw, fw, serial) {
    if (!App.honeybee_device) {
      console.warn("called populateDeviceInfo but does not have a honeybee device; returning to previous page.");
      App.goToPage("page1a");
      return;
    }
    // Merge the contents of two or more objects together into the first object. (http://api.jquery.com/jQuery.extend/)
    $.extend(App.honeybee_device, {hasDeviceInfo: true, device_name: name, hardware_version: hw, firmware_version: fw, serial_number: serial})

    Page1B.displayDeviceInfo();
    App.displaySpinner(false);
  },


  // helper funtions


  /**
   * Populate HTML with honeybee device information.
   */
  displayDeviceInfo: function() {
    if (!App.honeybee_device) {
      console.warn("called displayDeviceInfo but does not have a honeybee device; returning to previous page.");
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
   * Onclick listener for the "Request Feed Key" button.
   */
  onClickRequestFeedKey: function() {
    App.displaySpinner(true, "Requesting Feed Key...");
    ApplicationInterface.requestFeedKey();
  },


  populateFeedKey: function(feed_key) {
    Page1B.displayFeedKey();
    App.displaySpinner(false);
  },


  displayFeedKey: function() {
    if (!App.honeybee_device) {
      console.warn("called displayFeedKey but does not have a honeybee device; returning to previous page.");
      App.goToPage("page1a");
      return;
    }
    var feed_key = !(App.honeybee_device.esdr_feed_key) ? "--" : App.honeybee_device.esdr_feed_key;

    this.html_device_feed_key.text(feed_key);
  },

}
