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

    EsdrInterface.requestCreateNewDevice(accessToken, deviceName, serialNumber, function(deviceData) {
      console.log("requestCreateNewDevice success");
      console.log(deviceData);
      var deviceId = deviceData.data.id;
      EsdrInterface.requestCreateNewFeed(accessToken, deviceId, feedName, exposure, function(feedData) {
        console.log(feedData);
        console.log("requestCreateNewFeed success");
        Page3B.onFeedCreated(feedData.data, feedName, exposure);
      });
    });
  },


  onFeedCreated: function(json, feedName, exposure) {
    console.log("Page3B.onFeedCreated");
    App.honeybee_device.esdr_feed = json;
    App.honeybee_device.esdr_feed_name = feedName;
    App.honeybee_device.esdr_feed_exposure = exposure;
    console.log("apiKey="+json.apiKey);
    ApplicationInterface.setFeedKey(true, json.apiKey);
  },


  onFeedKeySent: function() {
    console.log("Page3B.onFeedKeySent");
    App.goToPage("page4");
  }

}
