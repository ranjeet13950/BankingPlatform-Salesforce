public with sharing class AccountDashboardController {

    // ✅ Wrapper class exposed to LWC
    public class AccountWrapper {
        @AuraEnabled public Account__c account { get; set; }
        @AuraEnabled public List<Transaction__c> transactions { get; set; }
        @AuraEnabled public List<Loan__c> loans { get; set; }
        @AuraEnabled public List<Loan_Detail__c> loanDetails { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static AccountWrapper getFullAccountData(Id accountId) {
        AccountWrapper wrap = new AccountWrapper();

        // --- ✅ Account, Branch, and Bank Info ---
        wrap.account = [
            SELECT Id, Name, Account_Number__c, Account_Type__c, Balance__c, Daily_Limit__c,
                   Phone_Number__c, 
                   Branch__r.Name, Branch__r.City__c, Branch__r.State__c, Branch__r.Contact__c,
                   Bank__r.Name, Bank__r.Type_of_Bank__c, Bank__r.Sector__c
            FROM Account__c
            WHERE Id = :accountId
            LIMIT 1
        ];

        // --- ✅ Transactions ---
        wrap.transactions = [
            SELECT Id, Name, Transaction_Type__c, Amount__c, Date__c, Status__c
            FROM Transaction__c
            WHERE Account__c = :accountId
            ORDER BY Date__c DESC
        ];

        // --- ✅ Loans ---
        wrap.loans = [
            SELECT Id, Name, Loan_Type__c, Loan_Amount__c, Rate_of_interest__c, Status__c, Remaining_Amount__c, EMI__c
            FROM Loan__c
            WHERE Account__c = :accountId
        ];

        // --- ✅ Loan Details ---
        wrap.loanDetails = [
            SELECT Id, Name, Amount_taken__c, Start_Date__c, End_Date__c, Status__c, Loan__r.Name
            FROM Loan_Detail__c
            WHERE Loan__r.Account__c = :accountId  // 🔥 FIXED: was Account__c before, should be Loan__r.Account__c
        ];

        return wrap;
    }
}
