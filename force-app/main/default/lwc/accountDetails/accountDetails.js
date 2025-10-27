import { LightningElement, api, track } from 'lwc';
import getAccountDetails from '@salesforce/apex/AccountDetailsController.getAccountDetails';

export default class AccountDetails extends LightningElement {
    @api recordId;
    @track account;
    @track error;
    @track isLoading = false;

    connectedCallback() {
        this.loadAccount();
    }

    loadAccount() {
        this.isLoading = true;
        getAccountDetails({ accountId: this.recordId })
            .then(result => {
                this.account = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.account = undefined;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleRefresh() {
        this.loadAccount();
    }

    get balanceClass() {
        if (this.account && this.account.Balance__c < 1000) {
            return 'low-balance';
        }
        return 'normal-balance';
    }
}
