import { LightningElement, track, wire } from 'lwc';
import getLatestAccounts from '@salesforce/apex/LaatestAccountController.latestAccounts';

export default class LatestAccounts extends LightningElement {
    @track accounts;
    @track error;

    columns = [
        { label: 'ID', fieldName: 'Id' },
        { label: 'Account Name', fieldName: 'Name' },
        { label: 'Account Number', fieldName: 'Account_Number__c' },
        { label: 'Phone', fieldName: '		Phone_Number__c' },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' }
    ];

    connectedCallback() {
        this.loadAccounts();
    }

    loadAccounts() {
        getLatestAccounts()
            .then(result => {
                this.accounts = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.accounts = undefined;
            });
    }
}
