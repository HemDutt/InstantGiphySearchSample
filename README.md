# InstantGiphySearchSample
# Objective :
Design an instant search feature that works on client side using a cache that does not exceed 10 MB of memory footprint on client.
1. Use Giphy Search Suggestions Endpoint - this returns the recommendations for instant search based on popularity.This uses some server side algo to manage the recommendations at an aggregate level of many users.
2. On the client side you have a page for user to input the search string with a search box and a dropdown that popup with the recommendations
3. On the client side you will have a cache where you store the name values received from server side recommendations
4. When user starts typing,if there is a pause of 200ms then you trigger the logic to fetch a list of recommendations to populate the dropdown
5. The recommendations fetch logic has the following workflow:

a) Get the recommendations stored locally first. At the same time trigger a request on a different thread to fetch server side updates.

b) The dropdown initially has recommendations of items fetched from client cache. These are ordered alphabetically.

c) If response from server arrives then we update the client cache with new name values and enhance the cache.

d) If server response arrives while user is viewing dropdown, we should not replace the items in view port. Instead only items in scroll down should be updated. Scroll to top should remain as-is since user will otherwise lose context of items already traversed.

e) If user clicks on a recommendation or just the search button for a given string input then we use the Giphy Search Endpoint. We just need to dump the response JSON to a text area. No fancy UI required here.

f) If the response from server comes after user types additional letters or removes letters then we invalidate the previous fetch of recommendations and start a new fetch.
