import { LightningElement, track, wire } from 'lwc';
import createNewAccount from '@salesforce/apex/AccountFormController.createNewAccount';
import getBankOptions from '@salesforce/apex/AccountFormController.getBankOptions';
import getBranchOptions from '@salesforce/apex/AccountFormController.getBranchOptions';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account__c';
import ACCOUNT_TYPE_FIELD from '@salesforce/schema/Account__c.Account_Type__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountCreationForm extends LightningElement {
    @track name;
    @track bankId;
    @track branchId;
    @track accountType;
    @track dailyLimit;
    @track minimumBalance;
    @track phoneNumber;

    @track bankOptions = [];
    @track branchOptions = [];
    @track accountTypeOptions = [];

    // Get Object Info
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accountInfo;

    // Dynamically get picklist values for Account_Type__c
    @wire(getPicklistValues, {
        recordTypeId: '$accountInfo.data.defaultRecordTypeId',
        fieldApiName: ACCOUNT_TYPE_FIELD
    })
    wiredAccountTypeValues({ data, error }) {
        if (data) {
            this.accountTypeOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error fetching Account Type picklist:', error);
        }
    }

    // Fetch Bank and Branch records
    @wire(getBankOptions)
    wiredBanks({ data, error }) {
        if (data) {
            this.bankOptions = data.map(b => ({ label: b.Name, value: b.Id }));
        } else if (error) {
            console.error('Error fetching banks:', error);
        }
    }

    @wire(getBranchOptions)
    wiredBranches({ data, error }) {
        if (data) {
            this.branchOptions = data.map(b => ({ label: b.Name, value: b.Id }));
        } else if (error) {
            console.error('Error fetching branches:', error);
        }
    }

    handleInputChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    handleCreate() {
        createNewAccount({
            name: this.name,
            bankId: this.bankId,
            branchId: this.branchId,
            accountType: this.accountType,
            dailyLimit: this.dailyLimit,
            minimumBalance: this.minimumBalance,
            phoneNumber: this.phoneNumber
        })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success 🎉',
                        message: 'Account created successfully!',
                        variant: 'success'
                    })
                );
                this.resetForm();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error ❌',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    resetForm() {
        this.name = '';
        this.bankId = '';
        this.branchId = '';
        this.accountType = '';
        this.dailyLimit = '';
        this.minimumBalance = '';
        this.phoneNumber = '';
    }
}
