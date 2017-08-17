var Page3B = {

  html_select_exposure: null,
  html_feed_name: null,
  html_button_submit: null,


  initialize: function() {
    console.log("Page3A.initialize");

    this.html_select_exposure = $("#feed_exposure");
    this.html_feed_name = $("#feed_name");
    this.html_button_submit = $("#submit-feed");
    $("#submit-feed").off("click");
    $("#submit-feed").on("click", Page3B.onClickSubmit);
  },


  onClickSubmit: function() {
    console.log("Page3B.onClickSubmit");
    var accessToken = App.esdr_account.accessToken;
    var deviceName = App.honeybee_device.device_name;
    var serialNumber = App.honeybee_device.serial_number;
    var feedName = Page3B.html_feed_name.val();
    var exposure = Page3B.html_select_exposure.val();

    // TODO wait for success before create new feed
    EsdrInterface.requestCreateNewDevice(accessToken, deviceName, serialNumber, function(deviceData) {
      console.log("requestCreateNewDevice success");
      console.log(deviceData);
      var deviceId = deviceData.data.id;
      EsdrInterface.requestCreateNewFeed(accessToken, deviceId, feedName, exposure, function(feedData) {
        console.log(feedData);
        console.log("requestCreateNewFeed success");
        Page3B.onFeedCreated(feedData.data);
      });
    });
  },


  onFeedCreated: function(json) {
    console.log("Page3B.onFeedCreated");
    App.honeybee_device.esdr_feed = json;
    console.log("apiKeyReadOnly="+json.apiKeyReadOnly);
    // TODO send apiKey to honeybee device via ble
    App.goToPage("page4");
  }

}
