/*
    Copyright (c) 2019, 501Commons.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/

public virtual with sharing class Collab_CTRL_Account {

    //  Dynamic Object - https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/pages_dynamic_vf_globals_objecttype.htm
    private String objType;
    public sObject obj { 
        get; 
        set {
	          setObjectType(value);
        } 
    }

    // The sObject type as a string
    public String getObjectType() {
    	  return(this.objType);
    }
    public String setObjectType(sObject newObj) {
        this.objType = newObj.getSObjectType().getDescribe().getName();
        return(this.objType);
    }

    public boolean redirect { get; private set; }
    public ID idRedirect { get; private set; }
    
    private String collaborative;

    public Account AccountRecord {
        get {
            if (AccountRecord == null) {
                AccountRecord = new Account();
            }

            return AccountRecord;
        }
        set;
    }

    // constructor
    public Collab_CTRL_Account() {
        new Collab_CTRL_Account(null);
    }

    public Collab_CTRL_Account(ApexPages.StandardController controller) {

        redirect = false;

        this.AccountRecord = (Account)controller.getRecord();
        if (String.isBlank(this.AccountRecord.Id)) {
            return;
        }

        this.obj = (sObject)this.AccountRecord;

        if (Test.isRunningTest()) {
            this.collaborative = 'Casino_Road';
        }

        if (String.isBlank(this.collaborative)) {
            this.collaborative = Collab_SharedCode.GetCollaborativeDeveloperName(Collab_SharedCode.GetHouseholdIdFromAccount(this.AccountRecord.Id));
        }

        // Account - Get list of fields FROM fieldset
        List<String> listAccountFields = new List<String>();
        for (Schema.FieldSetMember f : this.getAccountStandardFields()) {
            listAccountFields.add(f.getFieldPath());
        }

        // Account - Required fields
        if (!listAccountFields.contains('Id')) {
            listAccountFields.add('Id');
        }

        String strSoql = 'SELECT ' + String.join(listAccountFields, ',');
        strSoql += ' FROM Account WHERE Id = \'' + this.AccountRecord.Id + '\'';

        System.debug('Collab_CTRL_Contact::Collab_CTRL_Contact Account soql: ' + strSoql);
        for (Account AccountExisting :Database.query(strSoql)) {
            this.AccountRecord = AccountExisting;
            System.debug('Collab_CTRL_Account::Collab_CTRL_Account query Account record: ' + this.AccountRecord);
            break;
        }
    }   
    
    // getter - reference in Visualforce as AccountStandardFields
    public List<Schema.FieldSetMember> getAccountStandardFields() {

        String partnerRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Organization' LIMIT 1].Id;
        if (this.AccountRecord.RecordTypeId == partnerRecordTypeId) {
            return null;
        }

        return fieldSetAccountStandardActive.getFields();
    }

    public Schema.FieldSet fieldSetAccountStandardActive {
        get {

            String fieldSetNameMetadata = Collab_SharedCode.GetFieldSetName(Collab_SharedCode.FieldSetScenarios.Custom_Account, this.collaborative);
            for (String fieldSetName :Schema.SObjectType.Account.fieldSets.getMap().keySet()) {

                // Check for custom fields set
                if (fieldSetName.equalsIgnoreCase(fieldSetNameMetadata)) {
                    return Schema.SObjectType.Account.fieldSets.getMap().get(fieldSetNameMetadata);
                }
            }

            return null;
        }
        set;
    }

    // status string for reporting the results of saving.
    public String strSaveResults { get; set; }

    //save the Accounts created or modified
    public virtual PageReference SaveAccount() {
        
        strSaveResults = null;
        
        try {
            
            update this.AccountRecord;

            return null;

        } catch (Exception e) {
            strSaveResults = Label.Collab_labelAccountErrorOnSave;
            ApexPages.addMessages(e); 

            return null;
        }
    }

    //save the Accounts modified, and then close the page.
    public virtual PageReference SaveAndCloseAccount() {
        SaveAccount();
        if (ApexPages.hasMessages(ApexPages.Severity.ERROR) ||
           ApexPages.hasMessages(ApexPages.Severity.FATAL) ||
            ApexPages.hasMessages(ApexPages.Severity.WARNING)) {
                return null; // don't close window.
        }
        
        return Cancel();    
    }
    
    // user wants to close this page
    public virtual PageReference Cancel() {
        idRedirect = this.AccountRecord.Id;
        
        // trigger our redirect component to redirect using javascript.
        redirect = true;
        return null;
    }
}