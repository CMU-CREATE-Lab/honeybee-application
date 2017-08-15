Honeybee Application
====================

The Honeybee Application is designed as an interface to the Honeybee BLE protocol which is used to communicate with Honeybee devices.


## Format
The project consists of 3 directories: **web**, **android**, **ios**. The **web** directory defines the user interface with HTML and JavaScript using jquery mobile for its widgets and css. The **android** and **ios** directories store the code for Android Studio and XCode projects which build apps for Android and iOS.


## Setup
1. `git clone --recursive [repo_link]`
2. Add your `web/js/secrets.js` file, which looks something like:
```
var CLIENT_ID = "my_client";
var CLIENT_SECRET = "Secret secret, I've got a secret!";
var PRODUCT_ID = 0;
```


## Web
all ui is handled as HTML and JavaScript and displayed by the platform's WebView implementation.

### Navigation
* **home** the initial screen loaded
* **page1a** scan for BLE devices
* **page1b** connect to a BLE device and request device information
* **page2a** scan for WiFi devices
* **page2b** send WiFi information to the Honeybee and wait for it to confirm that it is connected
* **page3a** ESDR Login credentials
* **page3b** Form for creating a new ESDR Feed
* **page4** Summary of all of the previous information

### Simulating events with JavaScript console
See [notes.txt](notes.txt) for some helpful JavaScript to run in the console for simulating scans and other events.
