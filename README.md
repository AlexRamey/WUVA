# WUVA
Radio App for WUVA 92.7

Website: [Live Radio and Song History](http://player.listenlive.co/46461)

## Triton Digital ##

**[iOS SDK Reference PDF](http://triton-sdk.media.streamtheworld.com/mobile_sdk/TD-Mobile-iOS-SDK-2.2.1.pdf)**

## ![Cover Art Archive](http://coverartarchive.org/img/navbar_logo.svg) ##

**[API reference](https://musicbrainz.org/doc/Cover_Art_Archive/API)**

A (potential) source for cover art. The process seems complicated, but the images are licensed for comercial use without restrictions and the API is available for free.

**Steps:**

1. Get the `cue_title` and `track_artist_name` from the Triton Station Player
2. Use `cue_title` and `track_artist_name` to query [MusicBrainz Search API](http://musicbrainz.org/doc/Development/XML_Web_Service/Version_2/Search) for the 36 character `MBID` ([info](https://musicbrainz.org/doc/MusicBrainz_Identifier))
    * Search for a `recording` with the title and artist
    * Url encode the parameters with the following syntax `<cue_title> AND artist:"<track_artist_name>"&limit=1&fmt=json`
    * Retrieve the `id` from the first element in the `releases` array
    	* If no `id` exists, a placeholder image should be displayed
    * Sample query:
    	* `cue_title`: Talladega
    	* `track_artist_name`: Eric Church
    	* Search url: [http://musicbrainz.org/ws/2/recording/?query=talladega%20AND%20artist:%22eric%20church%22&limit=1&fmt=json](http://musicbrainz.org/ws/2/recording/?query=talladega%20AND%20artist:%22eric%20church%22&limit=1&fmt=json)
    	* Resulting id: `886eb853-44be-46ef-a99f-4c61bf3c404a`
3. Use the `id` to construct an image url based on the the [Cover Art Archive API](https://musicbrainz.org/doc/Cover_Art_Archive/API)
	* Url syntax: [http://coverartarchive.org/release/id/front-500]()
	* Sample image url: *[http://coverartarchive.org/release/886eb853-44be-46ef-a99f-4c61bf3c404a/front-500](http://coverartarchive.org/release/886eb853-44be-46ef-a99f-4c61bf3c404a/front-500)*
4. Load and display the image
	* If no image exists, a placeholder image should be displayed
