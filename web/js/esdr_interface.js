var EsdrInterface = {

  // class variables
  request: null,
  clientId: CLIENT_ID,
  clientSecret: CLIENT_SECRET,
  productId: PRODUCT_ID,


  requestLogin: function(username, password, success) {
    var data = {
      grant_type: "password",
      client_id: EsdrInterface.clientId,
      client_secret: EsdrInterface.clientSecret,
      username: username,
      password: password
    };
    var headers = {};
    var url = "https://esdr.cmucreatelab.org/oauth/token";

    EsdrInterface.createAndSendAjaxRequest("POST", headers, data, url, success, EsdrInterface.onAjaxError);
  },


  requestCreateNewDevice: function(accessToken, deviceName, serialNumber, success) {
    var requestType = "POST";
    var headers = {
      Authorization: "Bearer " + accessToken,
    };
    var data = {
      name: deviceName,
      serialNumber: serialNumber,
    };
    var url = "https://esdr.cmucreatelab.org/api/v1/products/"+EsdrInterface.productId+"/devices";
    // TODO make ajax call
    // EsdrInterface.createAndSendAjaxRequest(requestType, headers, data, url, success, EsdrInterface.onAjaxError)
    console.log("----");
    console.log("requestCreateNewDevice");
    console.log(headers);
    console.log(data);
    console.log(url);
    console.log("====");
  },


  requestCreateNewFeed: function(accessToken, deviceId, feedName, exposure, success) {
    var requestType = "POST";
    var headers = {
      Authorization: "Bearer " + accessToken,
    };
    var data = {
      name: feedName,
      exposure: exposure,
    };
    var url = "https://esdr.cmucreatelab.org/api/v1/devices/"+deviceId+"/feeds";
    // TODO make ajax call
    // EsdrInterface.createAndSendAjaxRequest(requestType, headers, data, url, success, EsdrInterface.onAjaxError)
    console.log("----");
    console.log("requestCreateNewFeed");
    console.log(headers);
    console.log(data);
    console.log(url);
    console.log("====");
  },


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
