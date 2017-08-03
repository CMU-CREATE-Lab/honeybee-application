var App = {

  // application variables
  honeybee_device: null,
  esdr_account: null,


  // init/callback functions


  initialize: function () {
    console.log("onInitialize");
    $(document).on("pagecontainershow", App.onPageContainerShow);
  },


  initializePageId: function(pageId) {
    switch (pageId) {
      case "home":
        break;
      case "page1a":
        Page1A.initialize();
        break;
      case "page1b":
        Page1B.initialize();
        break;
      default:
        console.warn("unknown pageId="+pageId);
        break;
    }
  },


  onPageContainerShow: function (event, ui) {
    var pageId = $.mobile.pageContainer.pagecontainer("getActivePage")[0].id;
    console.log("onPageContainerShow: " + pageId);
    App.initializePageId(pageId);
  }

}


// HTML body onLoad
$(function() {
  console.log("onLoad");
  // avoid click delay on ios
  FastClick.attach(document.body);
  App.initialize();
  App.initializePageId($.mobile.pageContainer.pagecontainer("getActivePage")[0].id);
});
