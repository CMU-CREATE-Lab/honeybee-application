var Page1B = {

  html_device_name: null,
  html_device_hardware: null,
  html_device_firmware: null,
  html_device_serial_number: null,


  initialize: function() {
    console.log("Page1B.initialize");
    html_device_name = $("#device-name");
    html_device_hardware = $("#device-hw");
    html_device_firmware = $("#device-fw");
    html_device_serial_number = $("#device-serial");
  },


  displayDeviceInfo: function(name, hw, fw, serial) {
    html_device_name.text(name);
    html_device_hardware.text(hw);
    html_device_firmware.text(fw);
    html_device_serial_number.text(serial);
  }

}
