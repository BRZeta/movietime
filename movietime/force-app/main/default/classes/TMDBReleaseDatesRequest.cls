/**
 * @Business: Queueable Class to make the Details TMDB call out
 * @Date: 2018-01-21
 * @Author: JOSE ALCALA
 * ModifiedDate   Description
 * 2018-01-21     Initial Development
 * 2018-11-23     Get the home release date
*/
public class TMDBReleaseDatesRequest implements Queueable, Database.AllowsCallouts {
    
    private Set<Id> movieIds;
    
    public TMDBReleaseDatesRequest(Set<Id> queueableMovieSet){
    	this.movieIds = queueableMovieSet;
    }
    
    public void execute(QueueableContext context) {
        
        List<Movie__c> movies = [Select Id, TMDB_ID__c From Movie__c Where Id IN: movieIds];
        List<Movie__c> newInfo = New List<Movie__c>();
        Set<Id> movieIdsSet = new Set<Id>();
        
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
							if(re.type_Z == 3){
								system.debug('in code for release date type 3');
								m.Release_Date__c = date.valueOf(re.release_date);
							} else if (re.type_Z == 2){
								system.debug('in code for release date type 2');
								m.Release_Date__c = date.valueOf(re.release_date);
							} else if (re.type_Z == 1){
								system.debug('in code for release date type 1');
								m.Release_Date__c = date.valueOf(re.release_date);
							}
						} else {
							system.debug('in code for else: ' + AllDates);
							AllDates.add(date.valueOf(re.release_date));
                            AllDates.sort();
                            m.Release_Date__c = AllDates[0];
						}
						
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
				m.Get_Release_Dates_Callout_Made__c = True;
            	newInfo.add(m);
            	movieIdsSet.add(m.Id);
			}
    	}
		
		//update movie with release date
    	if(!newInfo.isEmpty()){
    		update newInfo;
    	}
    	//execute the second callout, getting the movie details
    	System.enqueueJob(new TMDBDetailsRequest(movieIdsSet));
    }
}