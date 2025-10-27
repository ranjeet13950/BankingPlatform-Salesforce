public with sharing class OpenAIService {

    // Call OpenAI API with a prompt and return response
    @AuraEnabled(cacheable=false)
    public static String getChatResponse(String prompt) {
        try {
            HttpRequest req = new HttpRequest();
            // Use your Named Credential here
            req.setEndpoint('callout:OpenAI_API/v1/chat/completions');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');

            // JSON body for ChatGPT API
            String body = JSON.serialize(new Map<String, Object>{
                'model' => 'gpt-3.5-turbo', // or gpt-4 if available
                'messages' => new List<Map<String, String>>{
                    new Map<String, String>{'role' => 'user', 'content' => prompt}
                },
                'max_tokens' => 300
            });

            req.setBody(body);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if(res.getStatusCode() == 200){
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                // Extract the response text
                List<Object> choices = (List<Object>) result.get('choices');
                if(choices.size() > 0){
                    Map<String, Object> firstChoice = (Map<String, Object>) choices[0];
                    Map<String, Object> message = (Map<String, Object>) firstChoice.get('message');
                    return (String) message.get('content');
                }
                return 'No response from OpenAI';
            } else {
                return 'Error: ' + res.getStatusCode() + ' ' + res.getStatus();
            }
        } catch(Exception e){
            return 'Exception: ' + e.getMessage();
        }
    }
}
