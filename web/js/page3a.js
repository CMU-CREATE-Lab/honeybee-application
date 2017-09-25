/**
 * Helper functions and callbacks for page3a.
 * @namespace Page3A
 */

var Page3A = {

  html_username: null,
  html_password: null,


  /**
   * Called after the page container shows the page.
   */
  initialize: function() {
    console.log("Page3A.initialize");

    this.html_username = $("#esdr-username");
    this.html_password = $("#esdr-password");
    $("#esdr-login").off("click");
    $("#esdr-login").on("click", Page3A.onClickLogin);
  },


  /**
   * Onclick listener for the Login button.
   */
  onClickLogin: function() {
    console.log("Page3A.onClickLogin");
    var username = $("#esdr-username").val();
    var password = $("#esdr-password").val();

    EsdrInterface.requestLogin(username, password, function(data) {
      console.log("got success");
      console.log(data);
      console.log("access token is " + data.access_token);
      var result = {
        username: username,
        userId: data.userId,
        accessToken: data.access_token,
      };
      Page3A.onEsdrLogin(result);
    });
  },


  /**
   * Called after successful response from ESDR to login with user credentials.
   * @param {json} json - JSON Response from ESDR API with account/token info.
   */
  onEsdrLogin: function(json) {
    console.log("Page3A.onEsdrLogin");
    App.esdr_account = json;
    App.goToPage("page3b");
  }

}
