caGrid iPhone App Build Instructions
------------------------------------

System Requirements:

Mac OS X, version 10.5.8 or greater
iPhone SDK, version 3.x


Steps to Build:

1) Install the JSON Framework

  These instructions are adapted from 
  http://iphone.zcentric.com/2008/08/05/install-jsonframewor/

  * Make a directory called SDKs in your ~/Library/ directory. 
  * Run the dependencies/JSONiPhoneSDK.dmg file. It will create a JSON directory.
  * Copy the JSON directory to SDKs. 
  * At this point you should have a directory called /Users/<username>/Library/SDKs/JSON with subdirectories iphoneos.sdk and iphonesimulator.sdk.

2) Use Xcode to open caGridApp/CaGrid.xcodeproj 

3) Build for "iPhone Simulator 3.0"


