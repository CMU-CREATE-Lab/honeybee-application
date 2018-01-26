/**
 * Helper functions and callbacks for page3FeedsNew.
 * @namespace Page3FeedsNew
 */

var Page3FeedsNew = {

  html_feed_name: null,
  html_feed_exposure: null,


  initialize: function() {
    console.log("Page3FeedsNew.initialize");

    this.html_feed_name = $("#new_feed_name");
    this.html_feed_exposure = $("#new_feed_exposure");
    $("#create-feed").off("click");
    $("#create-feed").on("click", Page3FeedsNew.onClickCreateFeed);
  },


  onClickCreateFeed: function() {
    var feedName = Page3FeedsNew.html_feed_name.val();
    if (feedName.length == 0) {
      ApplicationInterface.displayDialog("Please enter a name for your feed.");
      return;
    }
    var exposure = Page3FeedsNew.html_feed_exposure.val();
    var accessToken = App.esdr_account.accessToken;
    var deviceId = App.esdr_device.id;
    var ajaxResult = function(response) {
      console.log("requestCreateNewFeed success");
      console.log(response);
      App.goToPage("page3FeedsIndex");
    };

    EsdrInterface.requestCreateNewFeed(accessToken, deviceId, feedName, exposure, ajaxResult);
  },

}
