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
    * Url encode the parameters with the following syntax `"<cue_title>" AND artist:"<track_artist_name>"&limit=10`
    	* If `<track_artist_name>` contains a forward slash (`/`), which happens in some cases like where `<track_artist_name>` is `"artist_one F/ artist_two"` or when it's `"artist_one W/ artist_two"`, we take the substring from the beginning of `<track_artist_name>` to the first space found when searching backwards from the slash. In the above cases, this abbreviates the artist paramter to just `"artist_one"`. This is necessary b/c the CoverArt database doesn't recognize artists in this format.
    	* If `<cue_title>` or `<track_artist_name>` is 27 characters long (the max_length coming from Triton Station Player), we assume the information got cut off and do the following: 1) Don't Enclose the Parameter in `""` marks . 2) Add a `*` to the end of the parameter
    	* Example: [https://www.musicbrainz.org/ws/2/recording?query=SHE%27LL+LEAVE+YOU+WITH+A+SMI%2A+AND+artist:%22GEORGE+STRAIT%22&limit=10](https://www.musicbrainz.org/ws/2/recording?query=SHE%27LL+LEAVE+YOU+WITH+A+SMI%2A+AND+artist:%22GEORGE+STRAIT%22&limit=10)
    	* If a parameter contains some occurrences of either `'&'` or `'+'` but not both AND the above wildcard case (*) didn't apply to the parameter, we do the following: 1) `<param> = (<param>%20OR%20<param_2>)`, where param_2 is equivalent to param with `'&'` or `'+'` (whatever appeared in param) replaced by the other symbol. If we're dealing with <track_artist_name> note that <param> and <param_2> both include "artist:" This is necessary b/c sometimes these symbols are used interchangeably and inconsistently between the Triton and the CovertArt/MusicBrainz databases.
    	* Examples:
    		* [https://www.musicbrainz.org/ws/2/recording?query=%22Nothin%27%20Like%20You%22+AND+(artist:%22Dan+%2B+Shay%22%20OR%20artist:%22Dan+%26+Shay%22)](https://www.musicbrainz.org/ws/2/recording?query=%22Nothin%27%20Like%20You%22+AND+(artist:%22Dan+%2B+Shay%22%20OR%20artist:%22Dan+%26+Shay%22)
    		* [https://www.musicbrainz.org/ws/2/recording?query=(%22Talladega%22%20OR%20%22Springsteen%22)+AND+artist:%22Eric+Church%22](https://www.musicbrainz.org/ws/2/recording?query=(%22Talladega%22%20OR%20%22Springsteen%22)+AND+artist:%22Eric+Church%22) where you can imagine that `Springsteen` and `Talladega` are identical phrases except for one contains `+` while the other contains `&`.
    
    * Retrieve the `id` for all of the `releases`
    	* If no `id`s exists, a placeholder image should be displayed
    * Sample query:
    	* `cue_title`: Talladega
    	* `track_artist_name`: Eric Church
    	* Search url: [https://musicbrainz.org/ws/2/recording/?query="talladega"%20AND%20artist:%22eric%20church%22&limit=10](https://musicbrainz.org/ws/2/recording/?query=talladega%20AND%20artist:%22eric%20church%22&limit=10)
    	* A Resulting id: `9ca2e2db-bc6e-4f71-b16f-63020aa4b651` (among others)
3. For all release_ids (up to 10), fire off concurrent requests with the following format:
	* Use the `id` to construct an image url based on the the [Cover Art Archive API](https://musicbrainz.org/doc/Cover_Art_Archive/API)
	* Url syntax: [http://coverartarchive.org/release/id/front-500]()
	* Sample image url: *[https://coverartarchive.org/release/9ca2e2db-bc6e-4f71-b16f-63020aa4b651/front-500](https://coverartarchive.org/release/9ca2e2db-bc6e-4f71-b16f-63020aa4b651/front-500)*
4. Each result should write it's result back to it's respective spot in an array, based on order requests were fired off and also order result_ids were found in the search. When all requests are done, step through the array sequentially. If we find image data, use it (priority goes to higher search results). If we exhaust the array and request provided image data, use a default image.
5. Load and display the image
	* If no image exists, a placeholder image should be displayed
