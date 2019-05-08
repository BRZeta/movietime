/**
 * @Business: Invocable Method to be used from Process Builder to get Home Release Date
 * @Date: 2018-01-18
 * @Author: JOSE ALCALA
 * ModifiedDate   Description
 * 2018-11-25     Initial Development
*/
public class TMDBHomeReleaseRequest {
	
	@InvocableMethod(
	label='Get Home Release Date' description='Sends a call out to TMDB API to get the home release date')
	public static void getReleaseDates(List<ID> movieIds) {
		getReleaseDatesFuture(movieIds);
	}
	
	@future(callout=true)
  	public static void getReleaseDatesFuture(List<ID> movieIds) {
    	
    	List<Movie__c> movies = [Select Id, Name, TMDB_ID__c, Release_Date__c From Movie__c Where Id IN: movieIds];
    	List<Movie__c> newInfo = new List<Movie__c>();
    	
    	for(Movie__c m : movies){

			String searchURL = 'https://api.themoviedb.org/3/movie/' +m.TMDB_ID__c + '/release_dates?api_key=' + 
								System.Label.TMDB_API_Key;

			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(searchURL);
			request.setMethod('GET');
			HttpResponse response = http.send(request);
			System.debug(response.getBody());

			if (response.getStatusCode() == 200) {
				// Send the response to the custom parse class to parse the data
				MovieDateParseWrapper.MovieDateParse movie = MovieDateParseWrapper.parse(response.getBody());
				
				//Get the release date of the movie. If only 1 date, then insert that one, if more than one insert US general release date
				//If the movie was not released in the US and has more than one release date get the earlist date
				list<date> AllDates = new list<date>();
				for(MovieDateParseWrapper.results d : movie.results){
					
					system.debug('value of d: '+ d);
					
					for(MovieDateParseWrapper.Release_dates re: d.release_dates){
						system.debug('value of re: ' + re);
						
						if(d.iso_3166_1 == 'US'){
							system.debug('in code for release date US');
							
							if(re.type_Z == 4){
								system.debug('in code for release date type 4');
								m.Home_Release_Date__c = date.valueOf(re.release_date);
								break;
							} else if(re.type_Z == 5){
								system.debug('in code for release date type 5');
								m.Home_Release_Date__c = date.valueOf(re.release_date);
							}
						}
					}
				}
				m.Get_Home_Release_Date_Call_Out_Made__c = True;
            	newInfo.add(m);
			}
    	}
		
		//update movie with release date
    	if(!newInfo.isEmpty()){
    		update newInfo;
    	}
  	}
}