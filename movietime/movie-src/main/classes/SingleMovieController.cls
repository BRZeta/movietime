public class SingleMovieController {
    
    //public Movie__c movie {get;set;}
    public string TMDBId {get;set;}
    
    public SingleMovieController(){

        TMDBId = ApexPages.currentPage().getParameters().get('TMDB');
    }
    
    public Movie__c getMovie() {
        
        Movie__c movie;
        
        try {
            movie = [Select Id, Name, TMDB_ID__c, Backdrop__c, Poster_Link__c, Overview__c, Combined_Rating__c, Anticipation__c, Baby_Harimau_Rating__c,
            		 Watched__c, Comments__c, Genres__c, Harimau_Rating__c, Key_Words__c, Location__c, Money_Rating__c, Original_Language__c,
            		 Payment_Method__c, Price__c, Production_Company__c, Rating__c, Release_Date__c, Showing__c, Tagline__c, Theater__c, View_Date__c 
        			 From Movie__c Where TMDB_ID__c =: TMDBId];
            
        } catch(Exception ex) {
            logException('Exception in getMovie', ex);
        }
        return movie;
        
    }
    
    private void logException(String errorTitle, Exception ex) {
        String placholderMsg = '\n {0} \n Error: {1} \n Stack Trace: {2}';
        String[] fillers = new String[] {errorTitle, ex.getMessage(), ex.getStackTraceString()};
        System.debug(String.format(placholderMsg, fillers));
    }
}