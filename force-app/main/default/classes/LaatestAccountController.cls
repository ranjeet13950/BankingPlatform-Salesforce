public with sharing class LaatestAccountController {
    @AuraEnabled(cacheable=true)
    public static List<Account__c>latestAccounts(){
        return [SELECT Id, Name, Account_Number__c,	Phone_Number__c	, 
                CreatedDate 
            FROM Account__c
            ORDER BY CreatedDate DESC
            LIMIT 5];
    }
}