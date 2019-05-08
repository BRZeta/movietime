public class MoviesController {

    public String yearInstalled {get;set;}
    private Integer year = Date.Today().Year(); 
    public List<SelectOption> lstYear{get;set;}
    String section = 'All';
    public String boxOffice = Schema.sObjectType.Movie__c.getRecordTypeInfosByName().get('Box Office').getRecordTypeId();
    public String homeTheater = Schema.sObjectType.Movie__c.getRecordTypeInfosByName().get('Home Theater').getRecordTypeId();
	public Integer yearSearch {get;set;}
	public String movieName {get; set;}
	public Date releaseDate {get; set;}
	
    public MoviesController(){

        string year_s = ApexPages.currentPage().getParameters().get('year');
        lstYear = lstYearInstalled();
        doSearch(year_s);
    }

    public PageReference test() {
        return null;
    }
        
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All','All'));
        options.add(new SelectOption('Upcoming Movies','Upcoming Movies'));
        options.add(new SelectOption('Suggested Movies','Suggested Movies'));
        options.add(new SelectOption('Box Office','Box Office'));
        options.add(new SelectOption('Home Theater','Home Theater'));
        return options;
    }
        
    public String getSection() {
        return section;
    }
        
    public void setSection(String section) {
        this.section = section;
    }

    public void doSearch(String year_s){

        Integer n = String.isNotBlank(year_s) 
                  ? Integer.valueOf(year_s) 
                  : (String.isBlank(yearInstalled) ? 0 : Integer.valueof(yearInstalled));
    }

    //list of movies for the upcoming section
    public List<Movie__c> getnewMovies() {
        
        List<Movie__c> listNewMovies;
        
        try {
            listNewMovies = [SELECT Id, Name, Poster_Link__c, Rating__c, Release_Date__c, Anticipation__c,
                          	 Combined_Rating__c, Location__c, View_Date__c, RecordTypeId, TMDB_ID__c
                             From Movie__c Where View_Date__c = null Order By Release_Date__c ASC];
            
        } catch(Exception ex) {
            logException('Exception in getNewMovies', ex);
        }
        return listNewMovies;
        
    }

    //list of movies for the box office and home sections
    public List<Movie__c> getMovies() {

        List<Movie__c> listMovies;

        try {
            listMovies = [SELECT Id, Name, Money_Rating__c, Price__c, View_Date__c, Poster_Link__c, Rating__c,
                          Combined_Rating__c, Location__c, RecordTypeId, Release_Date__c, TMDB_ID__c
                          From Movie__c Where View_Date__c != null Order By View_Date__c DESC];
        } catch(Exception ex) {
            logException('Exception in getMovies', ex);
        }
        return listMovies;
    }
    
    //list of movies that were searched for in the search section
    public List<Movie__c> getSearchedMovies() {

        List<Movie__c> listSearchedMovies;

        try {
            listSearchedMovies = [SELECT Id, Name, Money_Rating__c, View_Date__c, Poster_Link__c, Rating__c, Overview__c,
                          Combined_Rating__c, Location__c, Release_Date__c, Genres__c, Key_Words__c, TMDB_ID__c
                          From Movie__c Where (Name LIKE : '%' + movieName + '%' 
    									OR Genres__c includes (:movieName)
    									OR Key_Words__c LIKE : '%' + movieName + '%') Order By View_Date__c DESC];
        } catch(Exception ex) {
            logException('Exception in getMovies', ex);
        }
        return listSearchedMovies;
    }
    
    private void logException(String errorTitle, Exception ex) {
        String placholderMsg = '\n {0} \n Error: {1} \n Stack Trace: {2}';
        String[] fillers = new String[] {errorTitle, ex.getMessage(), ex.getStackTraceString()};
        System.debug(String.format(placholderMsg, fillers));
    }

    // get year viewed    
    public List<SelectOption> lstYearInstalled() {
        List<SelectOption> options = new List<SelectOption>();
        Integer i = year;
        
        options.add(new SelectOption('','- ALL -'));
        while ( i >= year-8){
            options.add(new SelectOption(i+'',i+''));
            i--;
        }
        if(!options.isEmpty()) yearInstalled = options.get(0).getValue();
        
        return options;
    }
    
    public void save(){
    	
    	if(movieName != null && releaseDate != null){
    		List<Movie__c> movieList = [Select Id, Name From Movie__c Where Name =: movieName];
	    	system.debug(movieList);
	    	List<Movie__c> newMovies = new List<Movie__c>();
	    	
	    	if(movieList.isEmpty()){
	    		Movie__c m = new Movie__c(
		    	Name = movieName,
		    	Release_Date__c = releaseDate,
		    	RecordTypeId = homeTheater
		    	);
		    	newMovies.add(m);
	    	}
	    	
	    	Database.SaveResult[] srList = Database.insert(newMovies, false);
		    /*
		    for (Database.SaveResult sr : srList) {
		    	if(sr.isSuccess()){
		    		//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Suggested Movie has been added to the page!'));
		    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'my error msg');
    				ApexPages.addMessage(myMsg);
		    	} else {
		    		//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'It looks like there was an error when adding your movie.'));
		    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error when adding movie.');
    				ApexPages.addMessage(myMsg);
		    	}
		    }*/
    	}	
    }
    
    public void searchMovie(){
    	
    	if(movieName != null){
    		List<Movie__c> movieList = [Select Id, Name, Genres__c From Movie__c 
    									Where (Name LIKE : '%' + movieName + '%' 
    									OR Genres__c includes (:'%' + movieName + '%')
    									/*OR Key_Words__c includes (:'%' + movieName + '%')*/)]; 
	    	system.debug(movieList);
    	}	
    }
}