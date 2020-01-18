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

// Future Optimizations
//  Dynamic Object - https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/pages_dynamic_vf_globals_objecttype.htm
//  Abstract Class

global virtual with sharing class Collab_CTRL_Referral {

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

    global integer cEmptyContactRecords {
        get {
            return 1;
        }
    }

    public boolean redirect { get; private set; }
    public ID idRedirect { get; private set; }
    
    public List<Contact> contactRecords {
        get {
            if (contactRecords == null) {
                contactRecords = new List<Contact>();
            }

            return contactRecords;
        }
        set;
    }

    public Account accountRecord {
        get {
            if (accountRecord == null) {
                accountRecord = new Account();
            }

            return accountRecord;
        }
        set;
    }

    public Collab_Setting__mdt collaborativeRecord {
        get {
            if (collaborativeRecord == null) {
                collaborativeRecord = new Collab_Setting__mdt();
            }

            return collaborativeRecord;
        }
        set;
    }

    // constructor
    global Collab_CTRL_Referral() {
        System.debug(LoggingLevel.DEBUG, 'Collab_CTRL_Referral::Collab_CTRL_Referral');
        new Collab_CTRL_Referral(null);
    }

    global Collab_CTRL_Referral(ApexPages.StandardController controller) {

        redirect = false;

        this.accountRecord = (Account)controller.getRecord();
        this.obj = (sObject)this.accountRecord;

        Id userId = UserInfo.getUserId();
        if (!String.isBlank(userId)) {
            List<User> activeUsers = [SELECT AccountId, Name FROM User WHERE Id = :userId];
            if (!activeUsers.isEmpty()) {
                List<Collab_Setting__mdt> collabs = [SELECT Id, Account_Id__c, DeveloperName, New_Referral_Owner_Id__c, Eligibility_Report_URL__c FROM Collab_Setting__mdt WHERE Account_Id__c = :activeUsers[0].AccountId];
                if (!collabs.isEmpty()) {
                    this.collaborativeRecord = collabs[0];
                }
            }
        }

        String collaborativeDeveloperName = System.currentPageReference().getParameters().get('collab');

        // Security Injection Checks
        collaborativeDeveloperName = Collab_SharedCode.GetCodeSafeString(collaborativeDeveloperName);

        if (Test.isRunningTest()) {
            collaborativeDeveloperName = 'Making_Life_Work';
        }

        if (String.isBlank(this.collaborativeRecord.Id)) {
            this.collaborativeRecord = [SELECT Id, Account_Id__c, DeveloperName, New_Referral_Owner_Id__c, Eligibility_Report_URL__c FROM Collab_Setting__mdt WHERE DeveloperName = :collaborativeDeveloperName LIMIT 1];
        }

        // Rule - only change the owner if the referral created externally other clear out referral owner so new records don't get reassigned
        System.Debug(LoggingLevel.DEBUG, '*****Collab_CTRL_Referral:Collab_CTRL_Referral - UserInfo.getUserName(): ' + UserInfo.getUserName());
        if (!UserInfo.getUserName().containsIgnoreCase('referral')) {
            this.collaborativeRecord.New_Referral_Owner_Id__c = '';
        }

        System.Debug(LoggingLevel.DEBUG, '*****Collab_CTRL_Referral:Collab_CTRL_Referral - this.collaborativeRecord.New_Referral_Owner_Id__c: ' + this.collaborativeRecord.New_Referral_Owner_Id__c);

        // Contact - Get list of fields from Referral Contact fieldset
        List<String> listContactFields = new List<String>();
        for (Schema.FieldSetMember f : this.getReferralContactFields()) {
            listContactFields.add(f.getFieldPath());
        }

        // Contact - Required fields
        if (!listContactFields.contains('Id')) {
            listContactFields.add('Id');
        }
        if (!listContactFields.contains('OwnerId')) {
            listContactFields.add('OwnerId');
        }
        if (!listContactFields.contains('AccountId')) {
            listContactFields.add('AccountId');
        }
        if (!listContactFields.contains('LastName')) {
            listContactFields.add('LastName');
        }

        // Account - Get list of fields from Referral Account fieldset
        List<String> listAccountFields = new List<String>();
        for (Schema.FieldSetMember f : this.getReferralAccountFields()) {
            listAccountFields.add(f.getFieldPath());
        }

        // Account - Get list of fields from Eligibility fieldset
        for (Schema.FieldSetMember f : this.getEligibilityAccountFields()) {
            listAccountFields.add(f.getFieldPath());
        }

        // Account - Required fields
        //
        if (!listAccountFields.contains('Id')) {
            listAccountFields.add('Id');
        }

        if (!listAccountFields.contains('OwnerId')) {
            listAccountFields.add('OwnerId');
        }

        if (!listAccountFields.contains('Name')) {
            listAccountFields.add('Name');
        }

        if (!listAccountFields.contains('Collaborative__c')) {
            listAccountFields.add('Collaborative__c');
        }

        if (!String.isBlank(this.accountRecord.Id)) {

            String strSoql = 'SELECT ' + String.join(listContactFields, ',');
            strSoql += ' FROM Contact WHERE AccountId = \'' + this.accountRecord.Id + '\'';

            System.debug('Collab_CTRL_Referral::Collab_CTRL_Referral Contact soql: ' + strSoql);
            for (Contact contactExisting :Database.query(strSoql)) {
                this.contactRecords.add(contactExisting);
                System.debug('Collab_CTRL_Referral::Collab_CTRL_Referral query contact record: ' + contactExisting);
            }

            strSoql = 'SELECT ' + String.join(listAccountFields, ',');
            strSoql += ' FROM Account WHERE Id = \'' + this.accountRecord.Id + '\'';

            System.debug('Collab_CTRL_Referral::Collab_CTRL_Referral Account soql: ' + strSoql);
            for (Account accountExisting :Database.query(strSoql)) {
                this.accountRecord = accountExisting;
                System.debug('Collab_CTRL_Referral::Collab_CTRL_Referral query account record: ' + this.accountRecord);
                break;
            }

            this.accountRecord.Eligibility_Criteria__c = this.collaborativeRecord.Eligibility_Report_URL__c;
        }

        // Insert empty rows into contacts datatable
        AddMoreEmptyRowsToContacts();
    }   
    
    // getter - reference in Visualforce as ReferralContactFields
    public List<Schema.FieldSetMember> getReferralContactFields() {
        return fieldSetReferralContactActive.getFields();
    }

    public Schema.FieldSet fieldSetReferralContactActive {
        get {

            String fieldSetNameMetadata = Collab_SharedCode.GetFieldSetName(Collab_SharedCode.FieldSetScenarios.Referral_Contact, this.collaborativeRecord.DeveloperName);
            for (String fieldSetName :Schema.SObjectType.Contact.fieldSets.getMap().keySet()) {

                // Check for custom fields set
                if (fieldSetName.equalsIgnoreCase(fieldSetNameMetadata)) {
                    return Schema.SObjectType.Contact.fieldSets.getMap().get(fieldSetNameMetadata);
                }
            }

            return null;
        }
        set;
    }

    // getter - reference in Visualforce as ReferralAccountFields
    public List<Schema.FieldSetMember> getReferralAccountFields() {
        return fieldSetReferralAccountActive.getFields();
    }

    public Schema.FieldSet fieldSetReferralAccountActive {
        get {

            String fieldSetNameMetadata = Collab_SharedCode.GetFieldSetName(Collab_SharedCode.FieldSetScenarios.Referral_Account, this.collaborativeRecord.DeveloperName);
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

    // getter - reference in Visualforce as Eligibility StandardFields
    public List<Schema.FieldSetMember> getEligibilityAccountFields() {
        return fieldSetEligibilityAccount.getFields();
    }

    public Schema.FieldSet fieldSetEligibilityAccount {
        get {

            String fieldSetNameMetadata = Collab_SharedCode.GetFieldSetName(Collab_SharedCode.FieldSetScenarios.Eligibility_Account, this.collaborativeRecord.DeveloperName);
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

    //save the Contacts created or modified
    public virtual PageReference SaveReferral() {
        
        strSaveResults = null;
        
        try {

            // NPSP - Create Contact first which will create the Household
            //
            Boolean updateAccountOwner = false;
            Id householdId;            
            for (Contact contactRecord :this.contactRecords) {

                if (String.isBlank(contactRecord.LastName)) {
                    continue;
                }

                if (String.isBlank(contactRecord.Id)) {

                    if (!String.isBlank(householdId)) {
                        contactRecord.AccountId = householdId;
                    }

                    contactRecord.Collab_Name__c = this.collaborativeRecord.DeveloperName;
                    
                    insert contactRecord;

                    if (String.isBlank(householdId)) {
                        householdId = [SELECT AccountId FROM Contact WHERE Id = :contactRecord.Id LIMIT 1].AccountId;
                    }
                }
                else {
                    update contactRecord;
                }
            }

            if (!String.isBlank(this.accountRecord.Id)) {
                update this.accountRecord;
            }

            // Create a Referral Service Record
            // TBD

            return null;

        } catch (Exception e) {

            strSaveResults = Label.Collab_labelReferralErrorOnSave;
            ApexPages.addMessages(e); 

            return null;
        }
    }

    //save the Contacts modified, and then close the page.
    public virtual PageReference SaveAndCloseReferral() {

        SaveReferral();

        if (ApexPages.hasMessages(ApexPages.Severity.ERROR) ||
            ApexPages.hasMessages(ApexPages.Severity.FATAL) ||
            ApexPages.hasMessages(ApexPages.Severity.WARNING)) {
                return null; // don't close window.
        }

        return Cancel();    
    }
    
    // user wants to close this page
    public virtual PageReference Cancel() {

        if (UserInfo.getUserName().containsIgnoreCase('referral')) {
            Pagereference pageRef = new Pagereference('/referral/Collab_ReferralSubmitted');
            return pageRef;
        }

        idRedirect = this.accountRecord.Id;
        
        // trigger our redirect component to redirect using javascript.
        redirect = true;

        return null;
    }

    global virtual void AddMoreEmptyRowsToContacts() {
        try {
            if (this.contactRecords == null) return;

            for (integer i = 0; i < cEmptyContactRecords; i++) { 
                Contact contactRecord = new Contact();
                contactRecord.AccountId = this.accountRecord.Id;
                this.contactRecords.add(contactRecord);
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);            
        }       
    }

    // user wants to add more empty rows to the Contacts table
    global PageReference AddMoreEmptyRows() {

        AddMoreEmptyRowsToContacts();

        return null;
    }

}