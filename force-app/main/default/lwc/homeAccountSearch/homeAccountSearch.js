import { LightningElement, track } from 'lwc';
import searchAccounts from '@salesforce/apex/AccountSearchController.searchAccounts';
import { NavigationMixin } from 'lightning/navigation';

export default class HomeAccountSearch extends NavigationMixin(LightningElement) {
    @track searchKey = '';
    @track accounts = [];
    @track error;

    handleSearchChange(event) {
        this.searchKey = event.target.value;
        if (this.searchKey.length >= 2) {
            this.fetchAccounts();
        } else {
            this.accounts = [];
        }
    }

    fetchAccounts() {
        searchAccounts({ searchKey: this.searchKey })
            .then((result) => {
                this.accounts = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.accounts = [];
                console.error('Error fetching accounts:', error);
            });
    }

    handleAccountClick(event) {
        const accountId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                objectApiName: 'Account__c',
                actionName: 'view'
            }
        });
    }
}
