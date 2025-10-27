public with sharing class BankingAIService {

    @AuraEnabled
    public static String getBankingResponse(String userInput, Id accountId) {
        try {
            // Step 1: Fetch relevant Salesforce data
            String accountData = getAccountData(accountId);
            String transactionData = getTransactionData(accountId);
            String loanData = getLoanData(accountId);
            String branchData = getBranchData(accountId);

            // Step 2: Build prompt for OpenAI
            String prompt = 'You are a banking assistant. User query: ' + userInput +
                            '\nHere is the Salesforce data:' +
                            '\nAccount Info: ' + accountData +
                            '\nTransactions: ' + transactionData +
                            '\nLoans: ' + loanData +
                            '\nBranch Info: ' + branchData +
                            '\nPlease provide a concise and user-friendly response.';

            // Step 3: Call OpenAI API
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:OpenAI_API/v1/chat/completions');
            req.setMethod('POST');
            req.setHeader('Content-Type','application/json');

            String body = JSON.serialize(new Map<String,Object>{
                'model' => 'openai',
                'messages' => new List<Map<String,String>>{
                    new Map<String,String>{'role'=>'user','content'=>prompt}
                },
                'max_tokens' => 300
            });

            req.setBody(body);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if(res.getStatusCode() == 200){
                Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> choices = (List<Object>) result.get('choices');
                Map<String,Object> firstChoice = (Map<String,Object>) choices[0];
                Map<String,Object> message = (Map<String,Object>) firstChoice.get('message');
                return (String) message.get('content');
            } else if(res.getStatusCode() == 429){
                return 'OpenAI API rate limit exceeded. Please try again in a few seconds.';
            } else {
                return 'Error: ' + res.getStatusCode() + ' ' + res.getStatus();
            }

        } catch(Exception e){
            return 'Exception: ' + e.getMessage();
        }
    }

    private static String getAccountData(Id accountId){
        Account__c acc = [
            SELECT Id, Name, Phone_Number__c, Account_Type__c, Balance__c 
            FROM Account__c 
            WHERE Id = :accountId 
            LIMIT 1
        ];

        return 'Name: ' + acc.Name + 
               ', Type: ' + acc.Account_Type__c + 
               ', Balance: ' + acc.Balance__c + 
               ', Phone: ' + acc.Phone_Number__c;
    }

    private static String getTransactionData(Id accountId){
        List<Transaction__c> txns = [SELECT Id, Amount__c, Date__c FROM Transaction__c WHERE Account__c = :accountId ORDER BY Date__c DESC LIMIT 5];
        String result = '';
        for(Transaction__c t : txns){
            result += '[Date: ' + t.Date__c + ', Amount: ' + t.Amount__c + '] ';
        }
        return result;
    }

    private static String getLoanData(Id accountId){
        List<Loan__c> loans = [SELECT Id, Loan_Amount__c, Status__c FROM Loan__c WHERE Account__c = :accountId LIMIT 5];
        String result = '';
        for(Loan__c l : loans){
            result += '[Amount: ' + l.Loan_Amount__c + ', Status: ' + l.Status__c + '] ';
        }
        return result;
    }

    private static String getBranchData(Id accountId){
        Account__c acc = [SELECT Branch__r.Name, Branch__r.City__c, Branch__r.State__c FROM Account__c WHERE Id = :accountId LIMIT 1];
        if(acc.Branch__r != null){
            return 'Branch Name: ' + acc.Branch__r.Name + ', City: ' + acc.Branch__r.City__c + ', State: ' + acc.Branch__r.State__c;
        }
        return 'No branch info';
    }
}
