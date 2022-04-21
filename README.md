# README

* Ruby Version 2.7.0

* Rails Version 6.0.4

#### Instructions

* Clone the git repository and navigate to the application folder.
* Install ruby-2.7.1
* Rename `.env.example` to `.env`
* Run the command `bundle install`
* Run the test suite using `bundle exec rspec` to confirm if the setup is successful.
* Start the rails server using `bundle exec puma`
* Test the output using `curl localhost:3000`

#### Details

* API fetches the feed data from https://takehome.io/ social network endpoints
* Supported social media platforms are `facebook`, `twitter`, and `instagram`.
* Expected output from the takehome.io endpoint is a valid JSON for success case. You can check sample response from all social media [here](https://github.com/mukeshp112/social-media-api/tree/main/spec/fixtures)
* In case the response code is not 200 for a request to a particular social network which indicates something might be wrong, one of the following value is added corresponding to the social network in the application's response: 
  1. If the request failed due to timeout: `[{ error: 'Connection timed out, could not fetch records.' }]`
  2. If the request fails with 500 status the error from api is added.
  3. If the request fails with any other exception: `[{ error: 'Something went wrong, could not fetch records.' }]`

#### Future Enhancements

* Enhance existing specs to test multithreaded data fetch logic.
* Tools such as JRuby can be considered to achieve better parallelization.
* Error notifiers can be integrated as well as error classes can be introduced.
