var EsdrInterface = {

  // constants
  CLIENT_ID: "",
  CLIENT_SECRET: "",
  // class variables
  request: null,


  requestLogin: function(username, password, success) {
    var data = {
      grant_type: "password",
      client_id: EsdrInterface.CLIENT_ID,
      client_secret: EsdrInterface.CLIENT_SECRET,
      username: username,
      password: password
    };
    var headers = {};
    var url = "https://esdr.cmucreatelab.org/oauth/token";

    EsdrInterface.createAndSendAjaxRequest("POST", headers, data, url, success, EsdrInterface.onAjaxError);
  },


  requestCreateNewDevice: function() {},
  requestCreateNewFeed: function() {},


  createAndSendAjaxRequest: function(requestType, headers, data, url, onAjaxSuccess, onAjaxError) {
    if (this.request != null) {
      console.log("createAndSendAjaxRequest with non-null request; aborting old request.");
      this.request.abort();
      this.request = null;
    }

    // https://api.jquery.com/jQuery.ajax/
    this.request = $.ajax({
      type: requestType,
      dataType: "json",
      url: url,
      data: data,
      headers: headers,
      xhrFields: { withCredentials: false },
      success: onAjaxSuccess,
      error: onAjaxError,
    });
  },


  // onAjaxSuccess: function(data) {
  //
  // },
  //
  //
  onAjaxError: function(message) {
    console.log("got error");
    console.log(message);
  },

}
