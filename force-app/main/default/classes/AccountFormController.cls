public with sharing class AccountFormController {
    @AuraEnabled
    public static Account__c createNewAccount(
        String name,
        Id bankId,
        Id branchId,
        String accountType,
        Decimal dailyLimit,
        Decimal minimumBalance,
        String phoneNumber
    ) {
        Account__c acc = new Account__c();
        acc.Name = name;
        acc.Bank__c = bankId;
        acc.Branch__c = branchId;
        acc.Account_Type__c = accountType;
        acc.Daily_Limit__c = dailyLimit;
        acc.Minimum_Balance__c = minimumBalance;
        acc.Phone_Number__c = phoneNumber;

        insert acc;
        return acc;
    }
    @AuraEnabled(cacheable=true)
    public static List<Bank__c> getBankOptions() {
        return [SELECT Id, Name FROM Bank__c];
    }

    @AuraEnabled(cacheable=true)
    public static List<Branch__c> getBranchOptions() {
        return [SELECT Id, Name FROM Branch__c];
    }
}