var App = {


  initialize: function () {
    console.log("onInitialize");
    $(document).on("pagecontainershow", App.onPageContainerShow);
  },


  initializePageId: function(pageId) {
    switch (pageId) {
      case "home":
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
