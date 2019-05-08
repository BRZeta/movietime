public class HomeController {

    public String boxOffice = Schema.sObjectType.Movie__c.getRecordTypeInfosByName().get('Box Office').getRecordTypeId();
    public String homeTheater = Schema.sObjectType.Movie__c.getRecordTypeInfosByName().get('Home Theater').getRecordTypeId();
	
    public HomeController(){

    }

    //list of movies for the upcoming section
    public List<Movie__c> getnewMovies() {
        
        List<Movie__c> listNewMovies;
        
        try {
            listNewMovies = [SELECT Id, Name, Poster_Link__c, Rating__c, Release_Date__c, Anticipation__c,
                          	 Combined_Rating__c, Location__c, View_Date__c, RecordTypeId, TMDB_ID__c
                             From Movie__c Where View_Date__c = null AND Release_Date__c >=: system.today()
                             Order By Release_Date__c ASC LIMIT 5];
            
        } catch(Exception ex) {
            logException('Exception in getNewMovies', ex);
        }
        return listNewMovies;
        
    }

    //list of movies for the box office section
    public List<Movie__c> getTheaterMovies() {

        List<Movie__c> listTheaterMovies;

        try {
            listTheaterMovies = [SELECT Id, Name, Money_Rating__c, Price__c, View_Date__c, Poster_Link__c, Rating__c,
                          		 Combined_Rating__c, Location__c, RecordTypeId, Release_Date__c, TMDB_ID__c
                          		 From Movie__c Where View_Date__c != null AND RecordTypeId =: boxOffice
                          		 Order By View_Date__c DESC LIMIT 5];
        } catch(Exception ex) {
            logException('Exception in getMovies', ex);
        }
        return listTheaterMovies;
    }
    
    //list of movies for the box office section
    public List<Movie__c> getHomeMovies() {

        List<Movie__c> listHomeMovies;

        try {
            listHomeMovies = [SELECT Id, Name, Money_Rating__c, Price__c, View_Date__c, Poster_Link__c, Rating__c,
                          	  Combined_Rating__c, Location__c, RecordTypeId, Release_Date__c, TMDB_ID__c
                          	  From Movie__c Where View_Date__c != null AND RecordTypeId =: homeTheater
                          	  Order By View_Date__c DESC LIMIT 5];
        } catch(Exception ex) {
            logException('Exception in getMovies', ex);
        }
        return listHomeMovies;
    }
    
    private void logException(String errorTitle, Exception ex) {
        String placholderMsg = '\n {0} \n Error: {1} \n Stack Trace: {2}';
        String[] fillers = new String[] {errorTitle, ex.getMessage(), ex.getStackTraceString()};
        System.debug(String.format(placholderMsg, fillers));
    }
}