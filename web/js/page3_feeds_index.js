/**
 * Helper functions and callbacks for page3FeedsIndex.
 * @namespace Page3FeedsIndex
 */

var Page3FeedsIndex = {

  html_feed_select: null,
  feeds_hashmap: {},


  initialize: function() {
    console.log("Page3FeedsIndex.initialize");

    this.html_feed_select = $("#feed_select");
    $("#feeds-exist").show();
    $("#label-for-feed-create").show();
    $("#page-feeds-index-title").text("Feeds for "+App.esdr_device.name);
    $("#choose-feed").off("click");

    this.requestFeeds();
  },


  requestFeeds: function() {
    if (App.esdr_account == null) {
      App.goToPage("page3a");
      return;
    };
    var accessToken = App.esdr_account.accessToken;
    var deviceId = App.esdr_device.id;
    var success = function(result) {
      console.log(result);
      if (result.data.rows.length > 0) {
        Page3FeedsIndex.populateFeeds(result.data.rows);
        $("#choose-feed").on("click", Page3FeedsIndex.onClickChooseFeed);
      } else {
        console.log("no feeds to display in Page3FeedsIndex");
        $("#feeds-exist").hide();
        $("#label-for-feed-create").hide();
      }
      App.displaySpinner(false);
    };
    App.displaySpinner(true, "Requesting Feeds...");
    EsdrInterface.requestFeeds(accessToken, deviceId, success);
  },


  populateFeeds: function(feeds) {
    // clear current feeds
    Page3FeedsIndex.feeds_hashmap = {};
    Page3FeedsIndex.html_feed_select.find("option").remove();
    // populate new feeds
    for (i=0; i<feeds.length; i++) {
      Page3FeedsIndex.feeds_hashmap[i] = feeds[i];
      Page3FeedsIndex.html_feed_select.append('<option value="'+i+'">'+feeds[i].name+'</option>')
    }
    // refresh widget
    Page3FeedsIndex.html_feed_select.selectmenu("refresh", true);
  },


  onClickChooseFeed: function() {
    console.log("Page3FeedsIndex.onClickChooseFeed");
    var selectedFeed = Page3FeedsIndex.feeds_hashmap[Page3FeedsIndex.html_feed_select.val()];
    console.log("apiKey="+selectedFeed.apiKey);
    App.honeybee_device.esdr_feed = selectedFeed;
    App.honeybee_device.esdr_feed_name = selectedFeed.name;
    App.honeybee_device.esdr_feed_exposure = selectedFeed.exposure;
    App.honeybee_device.esdr_feed_key = selectedFeed.apiKey;
    App.displaySpinner(true, "Sending Feed Key to Honeybee...");
    ApplicationInterface.setFeedKey(true, selectedFeed.apiKey);
  },

}
