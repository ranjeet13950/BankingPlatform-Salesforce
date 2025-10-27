public with sharing class BankingGeminiService {

    @AuraEnabled(cacheable=true)
    public static String getGeminiResponse(String userInput, Id accountId) {
        
        // Step 1: Fetch relevant Salesforce data
        String accountData = getAccountData(accountId);
        String transactionData = getTransactionData(accountId);
        String loanData = getLoanData(accountId);
        String branchData = getBranchData(accountId);

        // Step 2: Build prompt for Gemini
        // Updated prompt to explicitly ask for Rupee symbol
        String systemPrompt = 'You are a helpful and friendly banking assistant for a user. ' +
                              'Your tone should be professional, concise, and easy to understand. ' +
                              'Always greet the user by name (e.g., "Hello [Name]"). ' +
                              'Use the provided Salesforce data to answer the user\'s query. ' +
                              'Do not make up information. If the data is not available, say so. ' +
                              'All financial amounts should be displayed using the Indian Rupee symbol (₹).';
        
        String fullPrompt = 'Salesforce Data:\n' +
                            'Account Info: ' + accountData + '\n' +
                            'Transactions: ' + transactionData + '\n' +
                            'Loans: ' + loanData + '\n' +
                            'Branch Info: ' + branchData + '\n\n' +
                            'User Query: ' + userInput;

        // Step 3: Call Gemini API via Named Credential
        try {
            HttpRequest req = new HttpRequest();
            
           
            req.setEndpoint('callout:Google_Gemini_API/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent');
            
            
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');

            // Construct the Gemini API Body
            Map<String, Object> payload = new Map<String, Object>{
                'contents' => new List<Object>{
                    new Map<String, Object>{
                        'parts' => new List<Object>{
                            new Map<String, String>{'text' => fullPrompt}
                        }
                    }
                },
                'systemInstruction' => new Map<String, Object>{
                    'parts' => new List<Object>{
                        new Map<String, String>{'text' => systemPrompt}
                    }
                }
            };
            
            req.setBody(JSON.serialize(payload));

            Http http = new Http();
            HttpResponse res = http.send(req);

            // Step 4: Parse the response
            if (res.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> candidates = (List<Object>) result.get('candidates');
                if (candidates != null && !candidates.isEmpty()) {
                    Map<String, Object> firstCandidate = (Map<String, Object>) candidates[0];
                    Map<String, Object> content = (Map<String, Object>) firstCandidate.get('content');
                    List<Object> parts = (List<Object>) content.get('parts');
                    Map<String, Object> firstPart = (Map<String, Object>) parts[0];
                    return (String) firstPart.get('text');
                }
                return 'Error: Could not parse AI response.';
            } else {
                return 'Error calling AI service: ' + res.getStatusCode() + ' ' + res.getStatus() + ' ' + res.getBody();
            }

        } catch (Exception e) {
            return 'Error calling AI service: ' + e.getMessage();
        }
    }

    // --- Data Fetching Methods (Updated with ₹) ---

    private static String getAccountData(Id accountId) {
        try {
            Account__c acc = [
                SELECT Id, Name, Phone_Number__c, Account_Type__c, Balance__c 
                FROM Account__c 
                WHERE Id = :accountId 
                LIMIT 1
            ];

            // Added ₹ symbol
            return 'Name: ' + acc.Name + 
                   ', Type: ' + acc.Account_Type__c + 
                   ', Balance: ₹' + acc.Balance__c + 
                   ', Phone: ' + acc.Phone_Number__c;
        } catch (Exception e) {
            return 'No account data found.';
        }
    }

    private static String getTransactionData(Id accountId) {
        try {
            List<Transaction__c> txns = [
                SELECT Id, Amount__c, Date__c 
                FROM Transaction__c 
                WHERE Account__c = :accountId 
                ORDER BY Date__c DESC 
                LIMIT 5
            ];
            
            if (txns.isEmpty()) {
                return 'No recent transactions found.';
            }

            String result = '';
            for(Transaction__c t : txns) {
                // Added ₹ symbol and formatted date
                result += '[Date: ' + t.Date__c.format() + ', Amount: ₹' + t.Amount__c + '] ';
            }
            return result;
        } catch (Exception e) {
            return 'Error fetching transaction data.';
        }
    }

    private static String getLoanData(Id accountId) {
        try {
            List<Loan__c> loans = [
                SELECT Id, Loan_Amount__c, Status__c 
                FROM Loan__c 
                WHERE Account__c = :accountId 
                LIMIT 5
            ];

            if (loans.isEmpty()) {
                return 'No loan data found.';
            }

            String result = '';
            for(Loan__c l : loans) {
                // Added ₹ symbol
                result += '[Amount: ₹' + l.Loan_Amount__c + ', Status: ' + l.Status__c + '] ';
            }
            return result;
        } catch (Exception e) {
            return 'Error fetching loan data.';
        }
    }

    private static String getBranchData(Id accountId) {
        try {
            Account__c acc = [
                SELECT Branch__r.Name, Branch__r.City__c, Branch__r.State__c 
                FROM Account__c 
                WHERE Id = :accountId 
                LIMIT 1
            ];
            
            if (acc.Branch__r != null) {
                return 'Branch Name: ' + acc.Branch__r.Name + ', City: ' + acc.Branch__r.City__c + ', State: ' + acc.Branch__r.State__c;
            }
            return 'No branch info';
        } catch (Exception e) {
            return 'Error fetching branch data.';
        }
    }
}

