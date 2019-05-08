/**
 * @Business: Standard Trigger
 * @Date: 2017-12-20
 * @Author: JOSE ALCALA
 * ModifiedDate   Description
 * 2017-12-20     Initial Development
*/
trigger MovieTrigger on Movie__c (after insert, after update, before insert, before update) {
    
    
    MovieTriggerHandler MHandler = new MovieTriggerHandler();

    MHandler.NewM = (List<Movie__c>) Trigger.new;
    MHandler.OldM = (List<Movie__c>) Trigger.old;
    MHandler.oldMap = trigger.oldMap;
    MHandler.IsBefore = Trigger.IsBefore;
    MHandler.IsAfter = Trigger.IsAfter;
    MHandler.IsUpdate = Trigger.IsUpdate;
    MHandler.IsInsert = Trigger.IsInsert;
    MHandler.IsDelete = Trigger.IsDelete;
    MHandler.IsUnDelete = Trigger.isUnDelete;

    MHandler.process();
    
}