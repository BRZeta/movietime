/**
 * @Business: Queueable Class to make the Details TMDB call out
 * @Date: 2018-01-21
 * @Author: JOSE ALCALA
 * ModifiedDate   Description
 * 2018-01-21     Initial Development
*/
public class TMDBKeywordsRequest implements Queueable, Database.AllowsCallouts {
	
	private Set<Id> movieIds;
    
    public TMDBKeywordsRequest(Set<Id> movieIdsSet){
    	this.movieIds = movieIdsSet;
    }
    
    public class MovieList {
        public KeyWordItem[] keywords;
    }
    public class KeyWordItem {
        public String CONTAINER, id, name;
    }
    
    public void execute(QueueableContext context) {
    	
    	List<Movie__c> movies = [Select Id, Name, TMDB_ID__c, Release_Date__c From Movie__c Where Id IN: movieIds];
    	List<Movie__c> newInfo = new List<Movie__c>();

    	for(Movie__c m : movies){

			String searchURL = 'https://api.themoviedb.org/3/movie/' +m.TMDB_ID__c + '/keywords?api_key=' + 
								System.Label.TMDB_API_Key;

			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(searchURL);
			request.setMethod('GET');
			HttpResponse response = http.send(request);
			System.debug(response.getBody());

			if (response.getStatusCode() == 200) {
				
				//Parse the data according to the results class
		        MovieList data = (MovieList)JSON.deserialize(response.getBody(), MovieList.class);
		        system.debug('data returned: '+ data);
		        
		        //Get the keywords associated with the movie, if there are none insert TBD
	        	Set<String> keyWordSet = new Set<String>();
		        for(KeyWordItem kw : data.keywords) {
		        	keyWordSet.add(kw.name);
		        }
		        
		        String finalKeyWords;
		        String keyWords = String.join(new List<String>(keyWordSet), ',');
		        
		        if(keyWords.length() > 255){
		        	String keyWordsFit = keyWords.subString(0,255);
		        	finalKeyWords = keyWordsFit;
		        } else {
		        	finalKeyWords = keyWords;
		        }
		        
		        if(keyWords != ''){
		        	m.Key_Words__c = finalKeyWords;
		        	newInfo.add(m);
		        } else {
		        	m.Key_Words__c = 'TBD';
		        	newInfo.add(m);
		        }
		        m.Get_Keywords_Callout_Made__c = True;
			}
    	}
    	
    	//update the movie with the keywords
    	if(!newInfo.isEmpty()){
    		update newInfo;
    	}
    }
}