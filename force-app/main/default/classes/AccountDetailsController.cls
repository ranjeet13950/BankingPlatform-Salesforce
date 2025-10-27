public with sharing class AccountDetailsController {
    @AuraEnabled
    public static Account__c getAccountDetails(Id accountId){
        return [SELECT Id, Name, Account_Number__c,	Phone_Number__c	, Balance__c, 
                   Account_Type__c, 	CreatedDate 
            FROM Account__c
            WHERE Id = :accountId
            LIMIT 1];
    }
}