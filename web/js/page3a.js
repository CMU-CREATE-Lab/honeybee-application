var Page3A = {

  html_username: null,
  html_password: null,


  initialize: function() {
    console.log("Page3A.initialize");

    this.html_username = $("#esdr-username");
    this.html_password = $("#esdr-password");
    $("#esdr-login").on("click", Page3A.onClickLogin);
  },


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
        access_token: data.access_token,
      };
      Page3A.onEsdrLogin(result);
    });
  },


  onEsdrLogin: function(json) {
    console.log("Page3A.onEsdrLogin");
    App.esdr_account = json;
    App.goToPage("page3b");
  }

}
