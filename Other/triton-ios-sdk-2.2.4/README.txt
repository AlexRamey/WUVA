In order to link TritonPlayerSDK, the frameworks SystemConfiguration, AdSupport, AVFoundation, MediaPlayer and CoreMedia must also be linked in Xcode.

== Changelog ==

TritonPlayerSDK-iOS-2.1 - 2015-05-01
    * Improvements for Advertising:
	- Possibility of loading a TDInterstitialAd directly from a TDAdRequestURLBuilder

    * Improvements in Triton Player
	- Added TDCuePointHistory class for receiving cue point history from the now playing history service.
	- Support for playing external on-demand streams (ads, podcasts) through Triton Player
	- Standalone player (TDSBMPlayer) for receiving stream metadata using Triton’s Side-band metadata technology 
	- Changed how state change and informations callbacks are handled by the player

TritonPlayerSDK-iOS-2.0.0 - 2015-02-25
    * Improvements for Advertising:
	- Created TDAdLoader to allow loading Triton ads and displaying it with custom UI
	- Created TDSyncBannerView to play a sync banner ad directly from a cue point
    * Improvements in the player connection provisioning
	- Support for playing an alternative mount when the current mount is geoblocked
	- player:wasGeoBlocked callback is deprecated. player:didFailConnectingWithError has geoblocking information
	- Improvements in the reconnection when a error occurs 

TritonPlayerSDK-iOS-1.1.0 - 2015-01-27
    * Included Advertising functionality (companion banners, interstitials)

TritonPlayerSDK-iOS-1.0.4 - 2014-12-08
    * Fixed a bug that was making the library crash when a cue point is not properly decoded

TritonPlayerSDK-iOS-1.0.3 - 2014-11-24
    * Requesting “When in use permission” for CLLocation manager when location tracking is enabled
    * Stream stops when headset is unplugged
    * Added shouldResumePlaybackAfterInterruption property to TritonPlayer
    * Re-included armv7s as a supported architecture 
    * Eliminated the need to use -all_load to load some categories
    * Minor improvements

TritonPlayerSDK-iOS-1.0.2 - 2014-10-30
    * Removed dependencies that were causing problems when compiling to 64-bit 
    * Minor improvements

TritonPlayerSDK-iOS-1.0.1 - 2014-10-08
    * Rebuilt library with iOS 8 SDK 
    * Minor improvements


TritonPlayerSDK-iOS-0.2.1 - 2014-06-10
    * Added TritonPlayerDelegate methods:
	- mute
	- unmute
	- setVolume

TritonPlayerSDK-iOS-0.2.0 - 2014-05-07
    * Changed TritonPlayerDelegate methods:
	- Standardized signatures with the player as a parameter
	- Error objects as parameters for error callbacks
	- Included callback support for handling phone interruptions
    * Fixed a bug which was preventing geo blocking notifications from being triggered
    * Added legacy AndoXML cue point format support
    * Included a simple VAST parser in the sample application for parsing companion banners ads
    * Minor improvements in the sample application


TritonPlayerSDK-iOS-0.1.0 - 2014-05-02
    * First version



