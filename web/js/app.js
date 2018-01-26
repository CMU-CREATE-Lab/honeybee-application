/**
 * Namespace for all app-related calls.
 * @namespace App
 */

var App = {

  // application variables
  honeybee_device: null,
  esdr_account: null,


  // helper functions


  /**
   * Shows or hides a spinner in HTML (jquerymobile CSS).
   * @param {boolean} visible - True indicates that we want to show the spinner; False hides the spinner.
   * @param {string} message - The message to be displayed on the spinner when {@link visible} is true.
   */
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


  /**
   * Clears the honeybee device object and redirects to the connect honeybee page.
   */
  disconnectHoneybeeDevice: function() {
    App.honeybee_device = {};
    App.goToPage("page1a");
  },


  /**
   * Load a new page in the jquerymobile HTML.
   * @param {string} pageId - HTML id for the jquerymobile page to be loaded.
   */
  goToPage: function(pageId) {
    switch (pageId) {
      case "home":
      case "page1a":
      case "page1b":
      case "page2a":
      case "page2b":
      case "page3a":
      case "page3b":
      case "page3DeviceNew":
      case "page3FeedsIndex":
      case "page3FeedsNew":
      case "page4":
        break;
      default:
        console.log("WARNING - could not find page with pageId="+pageId);
    }
    window.location = "#"+pageId;
  },


  // init/callback functions


  /**
   * Called after the HTML body loads.
   */
  initialize: function () {
    console.log("onInitialize");
    $(document).on("pagecontainershow", App.onPageContainerShow);
  },


  /**
   * Perform necessary initialization after page loads.
   * @param {string} pageId - HTML id for the jquerymobile page.
   */
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
      case "page3DeviceNew":
        Page3DeviceNew.initialize();
        break;
      case "page3FeedsIndex":
        // Page3FeedsIndex.initialize();
        break;
      case "page3FeedsNew":
        Page3FeedsNew.initialize();
        break;
      case "page4":
        Page4.initialize();
        break;
      default:
        console.warn("unknown pageId="+pageId);
        break;
    }
  },


  /**
   * Callback for pagecontainershow.
   */
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
