/**
 * Helper functions and callbacks for page3DeviceNew.
 * @namespace Page3DeviceNew
 */

var Page3DeviceNew = {

  html_device_name: null,


  initialize: function() {
    console.log("Page3DeviceNew.initialize");

    this.html_device_name = $("#device_name");
    $("#create-device").off("click");
    $("#create-device").on("click", Page3DeviceNew.onClickCreateDevice);
  },


  onClickCreateDevice: function() {
    // validate name is not blank
    var deviceName = Page3DeviceNew.html_device_name.val();
    if (deviceName.length == 0) {
      ApplicationInterface.displayDialog("Please enter a name for your device.");
      return;
    }

    var accessToken = App.esdr_account.accessToken;
    var serialNumber = App.honeybee_device.serial_number;
    var ajaxResult = function(response) {
      App.esdr_device = response.data;
      App.goToPage("page3FeedsIndex");
    };

    var productCheckResponse = function(productIdentifier) {
      EsdrInterface.requestCreateNewDevice(accessToken, productIdentifier, deviceName, serialNumber, ajaxResult);
    }
    var deviceNameFromProtocol = App.honeybee_device.device_name;
    EsdrInterface.findProductFromUniqueIdentifier(deviceNameFromProtocol,productCheckResponse);
  },

}
