/**
 * @Business: Standard Trigger Handler
 * @Date: 2017-12-20
 * @Author: JOSE ALCALA
 * ModifiedDate   Description
 * 2017-12-20     Initial Development
 * 2017-27-20     Created methods to call out to TMDB API to get movie information
 * 2018-01-18     Updated method to add genres
 * 2018-02-01     Removed methods for searching movie details and keywords by Id. They were moved to another class
*/
public class MovieTriggerHandler {
    
	public MovieTriggerHandler() {
        
    }
    public Boolean IsAfter  { get; set; }
    public Boolean IsBefore { get; set; }
    public Boolean IsInsert { get; set; }
    public Boolean IsUpdate { get; set; }
    public Boolean IsDelete { get; set; }
    public Boolean IsUnDelete { get; set; }
    public map<id,Movie__c> oldMap {get; set;}
    public map<id,Movie__c> newMap {get; set;}
    public List<Movie__c> NewM { get; set; }
    public List<Movie__c> OldM { get; set; }
    
    public void process() {

    	Set<Id> movieSearchSet = new Set<Id>();
    	Set<Id> queueableMovieSet = new Set<Id>();

    	if(IsAfter){
    		if(IsInsert){
    			for(Movie__c m : NewM){
    				//If a new movie is added and it has a release date add it to a set
    				if(m.Release_Date__c != null){
    					movieSearchSet.add(m.Id);
    				} 
    			}
    		}
    		if(IsUpdate){
    			for(Movie__c m: NewM){
    				//If a movie is updated with a TMDB Id, add it to a set
    				if(m.TMDB_ID__c != null && m.TMDB_ID__c != oldMap.get(m.Id).TMDB_ID__c){
    					queueableMovieSet.add(m.Id);
    				}
    			}
    		}
    	}

    	if(!movieSearchSet.isEmpty()){
    		//Send movies with a date to a method that will make an api callout
    		TMDBMovieIdRequest(movieSearchSet);
    	}
    	
    	if(!queueableMovieSet.isEmpty()){
    		//all the movies with a TMDB Id send to a queueable class that will cause a chain reaction and make a series of api calls
    		System.enqueueJob(new TMDBReleaseDatesRequest(queueableMovieSet));
    	}
    }
    
    //class used for the JSON parse
    public class MovieList {
        public MovieItem[] results;
    }
    
    //class used for the JSON parse
    public class MovieItem {
        public String CONTAINER, id, poster_path, title, release_date;
    }

	//make a callout to TMDB api and search for movies matching the Movie name
    @future(callout = true)
    public static void TMDBMovieIdRequest (Set<Id> movieSearchSet){
    	
    	List<Movie__c> movies = [Select Id, Name, TMDB_ID__c, Release_Date__c From Movie__c Where Id IN: movieSearchSet];
    	List<Movie__c> foundMovies = new List<Movie__c>();

    	for(Movie__c m : movies){

			String movieName = EncodingUtil.urlEncode( m.Name, 'UTF-8');
			String searchURL = 'https://api.themoviedb.org/3/search/movie?api_key=' + System.Label.TMDB_API_Key +
							   '&page=1&include_adult=false&query=' + movieName;

			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(searchURL);
			request.setMethod('GET');
			HttpResponse response = http.send(request);
			System.debug(response.getBody());

			if (response.getStatusCode() == 200) {
				
				// Parse the data according to the results class
		        MovieList data = (MovieList)JSON.deserialize(response.getBody(), MovieList.class);
		        system.debug('data returned: '+ data);
		        
		        // Iterate over the movie data if movie is found that matches the release year get the TMDB Id
		        for(MovieItem mi : data.results) {
		            if(date.valueOf(mi.release_date).year() == m.Release_Date__c.year()){
		            	m.TMDB_ID__c = mi.id;
		            	m.Get_Id_Callout_Made__c = True;
		            	foundMovies.add(m);
		            	break;
		            }
		        }
			}
    	}
		
		//update the movies that matched with the corresponding TMDB Id
    	if(!foundMovies.isEmpty()){
    		update foundMovies;
    	}
    }
}