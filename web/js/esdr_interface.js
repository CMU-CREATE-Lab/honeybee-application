/**
 * Namespace for all calls to ESDR's API.
 * @namespace EsdrInterface
 */

var EsdrInterface = {

  // class variables
  request: null,
  clientId: CLIENT_ID,
  clientSecret: CLIENT_SECRET,
  productId: PRODUCT_ID,


  /**
   * @callback deviceCallback
   * @param {json} device - The ESDR Device that was found or created.
   */
  /**
   * Given a serial number, determine if the authorized user has a Device already registered on ESDR. If so, return the ESDR Device information. Otherwise, request to create a new EDSR Device and return its information.
   * @param {string} accessToken - EDSR access token for an authorized user.
   * @param {string} deviceName - The name of the requested ESDR Device.
   * @param {string} serialNumber - The serial number of the requested ESDR Device.
   * @param {deviceCallback} callback - A callback that includes a device JSON object as its parameter.
   */
  findOrCreateDeviceFromSerialNumber: function(accessToken, deviceName, serialNumber, callback) {
    var findDeviceResponse = function(responseData) {
      if (responseData.data.rows.length > 0) {
        console.log("findOrCreateDeviceFromSerialNumber: found device id="+responseData.data.rows[0].id);
        callback(responseData.data.rows[0]);
      } else {
        var createDeviceResponse = function(response2data) {
          console.log("findOrCreateDeviceFromSerialNumber: created new device with id="+response2data.data.id);
          callback(response2data.data);
        };
        EsdrInterface.requestCreateNewDevice(accessToken, deviceName, serialNumber, createDeviceResponse);
      }
    };;
    var ajaxData = {
      "whereAnd": "serialNumber="+serialNumber,
    };

    EsdrInterface.requestDevices(accessToken, ajaxData, findDeviceResponse);
  },


  /**
  * Given a serial number, determine if the authorized user has the Device registered on ESDR. If so, return the ESDR Device information. Otherwise, return null.
  * @param {string} accessToken - EDSR access token for an authorized user.
  * @param {string} serialNumber - The serial number of the requested ESDR Device.
  * @param {deviceCallback} callback - A callback that includes a device JSON object (or null) as its parameter.
  */
  findDeviceFromSerialNumber: function(accessToken, serialNumber, callback) {
    var findDeviceResponse = function(responseData) {
      if (responseData.data.rows.length > 0) {
        console.log("findDeviceFromSerialNumber: found device id="+responseData.data.rows[0].id);
        callback(responseData.data.rows[0]);
      } else {
        console.log("findDeviceFromSerialNumber: no device found.");
        callback(null);
      }
    };;
    var ajaxData = {
      "whereAnd": "serialNumber="+serialNumber,
    };

    EsdrInterface.requestDevices(accessToken, ajaxData, findDeviceResponse);
  },


  /**
   * @callback ajaxSuccess
   * @param {json} data - The information received from a successful Ajax request.
   */
  /**
   * Request to log in with ESDR account credentials.
   * @param {string} username - EDSR username
   * @param {string} password - EDSR password
   * @param {ajaxSuccess} success - Ajax response.
   */
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

    EsdrInterface.createAndSendSynchronousAjaxRequest("POST", headers, data, url, success, function(error){
      ApplicationInterface.displayDialog("Invalid Username or Password");
    });
  },


  /**
   * Request a list of ESDR Devices for the user.
   * @param {string} accessToken - EDSR access token for an authorized user.
   * @param {json} ajaxData - The data passed in to the Ajax request.
   * @param {ajaxSuccess} success - Ajax response.
   */
  requestDevices: function(accessToken, ajaxData, success) {
    var headers = {
      Authorization: "Bearer " + accessToken,
    };
    var requestType = "GET";
    var url = "https://esdr.cmucreatelab.org/api/v1/devices";

    EsdrInterface.createAndSendSynchronousAjaxRequest(requestType, headers, ajaxData, url, success, EsdrInterface.onAjaxError);
  },


  /**
   * Request a list of ESDR Feeds for a given deviceId.
   * @param {string} accessToken - EDSR access token for an authorized user.
   * @param {int} deviceId - A Device ID associated with an EDSR Device.
   * @param {ajaxSuccess} success - Ajax response.
   */
  requestFeeds: function(accessToken, deviceId, success) {
    var headers = {
      Authorization: "Bearer " + accessToken,
    };
    var requestType = "GET";
    var url = "https://esdr.cmucreatelab.org/api/v1/feeds";
    var ajaxData = {
      "whereAnd": "deviceId="+deviceId,
    };

    EsdrInterface.createAndSendSynchronousAjaxRequest(requestType, headers, ajaxData, url, success, EsdrInterface.onAjaxError);
  },


  /**
   * Request to create a new ESDR device.
   * @param {string} accessToken - EDSR access token for an authorized user.
   * @param {string} deviceName - The name of the requested ESDR Device.
   * @param {string} serialNumber - The serial number of the requested ESDR Device.
   * @param {ajaxSuccess} success - Ajax response.
   */
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

    var onResponse = function(response) {
      var deviceId = response.data.id;
      EsdrInterface.requestAddStringPropertyToEsdrObject(accessToken,"devices",deviceId,"hwVersion",App.honeybee_device.hardware_version);
      EsdrInterface.requestAddStringPropertyToEsdrObject(accessToken,"devices",deviceId,"fwVersion",App.honeybee_device.firmware_version);
      EsdrInterface.requestAddStringPropertyToEsdrObject(accessToken,"devices",deviceId,"appVersion",App.APPLICATION_VERSION);
      success(response);
    }
    EsdrInterface.createAndSendSynchronousAjaxRequest(requestType, headers, data, url, onResponse, EsdrInterface.onAjaxError);
  },


  /**
   * Request to create a new ESDR Feed.
   * @param {string} accessToken - EDSR access token for an authorized user.
   * @param {int} deviceId - A Device ID associated with an EDSR Device.
   * @param {string} feedName - The name of the requested ESDR Feed.
   * @param {string} exposure - The exposure of the requested ESDR Feed; should be one of "outdoor", "indoor", "virtual".
   * @param {ajaxSuccess} success - Ajax response.
   */
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

    var onResponse = function(response) {
      var feedId = response.data.id;
      EsdrInterface.requestAddStringPropertyToEsdrObject(accessToken,"feeds",feedId,"appVersion",App.APPLICATION_VERSION);
      success(response.data);
    }
    EsdrInterface.createAndSendSynchronousAjaxRequest(requestType, headers, data, url, onResponse, EsdrInterface.onAjaxError);
  },


  /**
   * Helper to create and send an Ajax request.
   * @param {boolean} asynchronous - When true, do not assign request to class variable and do not abort any current (synchronous) requests.
   * @param {string} requestType - Should be one of the standard HTML request methods (see: {@link https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods}).
   * @param {json} headers - Headers to include in the HTTP request (see: {@link https://en.wikipedia.org/wiki/List_of_HTTP_header_fields}).
   * @param {josn} data - The data to include in the HTTP requst.
   * @param {string} url - The URL of the requested resource.
   * @param {ajaxSuccess} onAjaxSuccess - Callback function when the Ajax request receives a successful response.
   * @param {function} onAjaxError - Callback function when the Ajax request throws an error.
   */
  createAndSendAjaxRequest: function(asynchronous, requestType, headers, data, url, onAjaxSuccess, onAjaxError) {
    // https://api.jquery.com/jQuery.ajax/
    var temp = $.ajax({
      type: requestType,
      dataType: "json",
      url: url,
      data: data,
      headers: headers,
      xhrFields: { withCredentials: false },
      success: onAjaxSuccess,
      error: onAjaxError,
    });

    if (asynchronous) {
      return;
    }

    if (this.request != null) {
      console.log("createAndSendAjaxRequest with non-null request; aborting old request.");
      this.request.abort();
      this.request = null;
    }
    this.request = temp;
  },


  /**
   * Helper to create and send an Ajax request (see createAndSendAjaxRequest for param info).
   */
  createAndSendSynchronousAjaxRequest: function(requestType, headers, data, url, onAjaxSuccess, onAjaxError) {
    EsdrInterface.createAndSendAjaxRequest(false,requestType, headers, data, url, onAjaxSuccess, onAjaxError);
  },


  /**
   * Helper to add a string property to an esdr object (likely either "device" or "feed").
   * @param {string} accessToken - EDSR access token for an authorized user.
   * @param {string} objectNamePlural - the type of ESDR object being written to (should be of type "devices" or "feeds").
   * @param {int} objectId - the id for the ESDR object.
   * @param {string} propertyKey - The key for the string property.
   * @param {string} propertyValue - The value for the string property.
   */
  requestAddStringPropertyToEsdrObject: function(accessToken, objectNamePlural, objectId, propertyKey, propertyValue) {
    var requestType = "PUT";
    var headers = {
      Authorization: "Bearer " + accessToken,
    };
    var data = {
      type: "string",
      value: propertyValue,
    };
    var url = "https://esdr.cmucreatelab.org/api/v1/"+objectNamePlural+"/"+objectId+"/properties/"+encodeURIComponent(propertyKey);

    // no callbacks for success/fail but print to console
    var response = function(message) { console.log(message.data); };
    var error = function(message) { console.log(message); };
    EsdrInterface.createAndSendAjaxRequest(true, requestType, headers, data, url, response, error);
  },


  /**
   * Generic callback for Ajax.error in Ajax requests.
   * @param {json} message - The error returned from Ajax.
   */
  onAjaxError: function(message) {
    var errorString = (message.responseJSON.message) ? message.responseJSON.message : "unknown error";
    ApplicationInterface.displayDialog(errorString);
  },

}
