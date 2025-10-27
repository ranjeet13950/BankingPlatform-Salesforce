import { LightningElement, api, track } from 'lwc';
// This line is the fix:
// It imports the *correct* Apex method 'getGeminiResponse'
// and gives it the local alias 'getAiBankingResponse' for use in this file.
import getAiBankingResponse from '@salesforce/apex/BankingGeminiService.getGeminiResponse';
import './bankingChatLwc.css'; 


export default class BankingChatLwc extends LightningElement {
    @api recordId;
    @track userInput = '';
    @track formattedAiResponse;
    @track error;
    @track isLoading = false;

    // Getter for the button label
    get buttonLabel() {
        return this.isLoading ? 'Thinking...' : 'Get Response';
    }

    handleInputChange(event) {
        this.userInput = event.target.value;
    }

    handleGetResponse() {
        this.isLoading = true;
        this.error = undefined;
        this.formattedAiResponse = undefined; // Clear previous response

        // Call the Apex method using the imported alias
        getAiBankingResponse({ userInput: this.userInput, accountId: this.recordId })
            .then(result => {
                // Format the response to replace newlines with <br> tags
                this.formattedAiResponse = result.replace(/\n/g, '<br>');
                this.isLoading = false;
            })
            .catch(error => {
                this.error = 'Error calling AI service: ' + error.body.message;
                this.isLoading = false;
            });
    }
}

