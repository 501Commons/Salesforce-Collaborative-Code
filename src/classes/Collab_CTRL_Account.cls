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
    
    public boolean redirect { get; private set; }
    public ID idRedirect { get; private set; }
    
    private String collaborative;

    public Account accountRecord {
        get {
            if (accountRecord == null) {
                accountRecord = new Account();
            }

            return accountRecord;
        }
        set;
    }

    // constructor
    public Collab_CTRL_Account() {
        new Collab_CTRL_Account(null);
    }

    public Collab_CTRL_Account(ApexPages.StandardController controller) {

        redirect = false;

        this.accountRecord = (Account)controller.getRecord();
        if (String.isBlank(this.accountRecord.Id)) {
            return;
        }

        if (Test.isRunningTest()) {
            this.collaborative = 'Making_Life_Work';
        }

        if (String.isBlank(this.collaborative)) {
            this.collaborative = Collab_SharedCode.GetCollaborativeDeveloperName(this.accountRecord.Id);
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
        strSoql += ' FROM Account WHERE Id = \'' + this.accountRecord.Id + '\'';

        System.debug('Collab_CTRL_Contact::Collab_CTRL_Contact Account soql: ' + strSoql);
        for (Account accountExisting :Database.query(strSoql)) {
            this.accountRecord = accountExisting;
            System.debug('Collab_CTRL_Account::Collab_CTRL_Account query account record: ' + this.accountRecord);
            break;
        }
    }   
    
    // getter - reference in Visualforce as AccountStandardFields
    public List<Schema.FieldSetMember> getAccountStandardFields() {
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
            
            update this.accountRecord;

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
        idRedirect = this.accountRecord.Id;
        
        // trigger our redirect component to redirect using javascript.
        redirect = true;
        return null;
    }
}