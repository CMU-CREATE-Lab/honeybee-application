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
  },


  onEsdrLogin: function(json) {
    console.log("Page3A.onEsdrLogin");
    App.esdr_account = json;
    App.goToPage("page3b");
  }

}
