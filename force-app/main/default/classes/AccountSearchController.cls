public with sharing class AccountSearchController {
    @AuraEnabled(cacheable=true)
    public static List<Account__c> searchAccounts(String searchKey) {
        String key = '%' + searchKey + '%';

        return [
            SELECT Id, Name, Account_Number__c, Account_Type__c, Balance__c
            FROM Account__c
            WHERE Name LIKE :key
            OR Account_Number__c LIKE :key
            ORDER BY LastModifiedDate DESC
            LIMIT 10
        ];
    }
}
