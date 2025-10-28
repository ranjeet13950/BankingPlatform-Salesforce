import { LightningElement, api, wire, track } from 'lwc';
import getFullAccountData from '@salesforce/apex/AccountDashboardController.getFullAccountData';

export default class AccountDashboardLWC extends LightningElement {
    @api recordId; // Salesforce passes this automatically when on record page
    @track accountData;
    @track error;

    @wire(getFullAccountData, { accountId: '$recordId' })
    wiredAccountData({ error, data }) {
        if (data) {
            this.accountData = data;
            this.error = undefined;
            console.log('Fetched Account Data:', JSON.stringify(this.accountData));
        } else if (error) {
            this.error = error;
            this.accountData = undefined;
            console.error('Error loading account details:', error);
        }
    }

    get hasData() {
        return this.accountData && this.accountData.account;
    }
}
