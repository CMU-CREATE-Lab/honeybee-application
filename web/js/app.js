var App = {

  // application variables
  honeybee_device: null,
  esdr_account: null,


  // helper functions


  displaySpinner: function(visible, message) {
    if (visible) {
      $.mobile.loading( "show", {
        text: message,
        textVisible: true,
        theme: "b",
      });
    } else {
      $.mobile.loading("hide");
    }
  },


  disconnectHoneybeeDevice: function() {
    App.honeybee_device = {};
    App.goToPage("page1a");
  },


  goToPage: function(pageId) {
    // TODO check that we are using a real pageId (switch)
    window.location = "#"+pageId;
  },


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
      case "page2a":
        Page2A.initialize();
        break;
      case "page2b":
        Page2B.initialize();
        break;
      case "page3a":
        Page3A.initialize();
        break;
      case "page3b":
        Page3B.initialize();
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
  },

}


// HTML body onLoad
$(function() {
  console.log("onLoad");
  // avoid click delay on ios
  FastClick.attach(document.body);
  App.initialize();
  App.initializePageId($.mobile.pageContainer.pagecontainer("getActivePage")[0].id);
});
