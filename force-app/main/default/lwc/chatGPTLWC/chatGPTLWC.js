import { LightningElement, track } from 'lwc';
import getChatResponse from '@salesforce/apex/OpenAIService.getChatResponse';

export default class ChatGPTLWC extends LightningElement {
    @track userInput = '';
    @track messages = [];

    handleInputChange(event) {
        this.userInput = event.target.value;
    }

    sendMessage() {
        if(this.userInput.trim() === '') return;

        // Add user message
        this.messages.push({id: this.messages.length+1, role: 'User', content: this.userInput});

        getChatResponse({ prompt: this.userInput })
            .then(result => {
                // Add GPT response
                this.messages.push({id: this.messages.length+1, role: 'GPT', content: result});
                this.userInput = '';
            })
            .catch(error => {
                this.messages.push({id: this.messages.length+1, role: 'Error', content: error.body ? error.body.message : error});
            });
    }
}
