var Page1B = {

  html_device_name: null,
  html_device_hardware: null,
  html_device_firmware: null,
  html_device_serial_number: null,


  // TODO handle disconnect device by user navigation (otherwise we are connected to multiple devices with no control)


  initialize: function() {
    console.log("Page1B.initialize");
    this.html_device_name = $("#device-name");
    this.html_device_hardware = $("#device-hw");
    this.html_device_firmware = $("#device-fw");
    this.html_device_serial_number = $("#device-serial");

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
  },


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

}
