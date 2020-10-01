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

    public class InvalidParameterValueException extends Exception {}

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
                accountRecord = new Account(Id = '');
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

        System.debug(LoggingLevel.DEBUG, '*****Collab_CTRL_Referral.Collab_CTRL_Referral');
        redirect = false;

        this.accountRecord = (Account)controller.getRecord();
        System.debug(LoggingLevel.DEBUG, '*****Collab_CTRL_Referral.Collab_CTRL_Referral this.accountRecord: ' + this.accountRecord);
        this.obj = (sObject)this.accountRecord;
        System.debug(LoggingLevel.DEBUG, '*****Collab_CTRL_Referral.Collab_CTRL_Referral this.obj: ' + this.obj);

        if (Test.isRunningTest()) {

            List<Collab_Setting__mdt> collabs = [SELECT Id, Account_Id__c, DeveloperName, New_Referral_Owner_Id__c, Eligibility_Report_URL__c FROM Collab_Setting__mdt LIMIT 1];
            if (!collabs.isEmpty()) {
                this.collaborativeRecord = collabs[0];
            }
        }

        if (String.isBlank(this.collaborativeRecord.Id)) {

            String collaborativeDeveloperName = System.currentPageReference().getParameters().get('collab');

            if (!String.isBlank(collaborativeDeveloperName)) {

                // Security Injection Checks
                collaborativeDeveloperName = Collab_SharedCode.GetCodeSafeString(collaborativeDeveloperName);
    
                List<Collab_Setting__mdt> collabs = [SELECT Id, Account_Id__c, DeveloperName, New_Referral_Owner_Id__c, Eligibility_Report_URL__c FROM Collab_Setting__mdt WHERE DeveloperName = :collaborativeDeveloperName LIMIT 1];
                if (!collabs.isEmpty()) {
                    this.collaborativeRecord = collabs[0];
                }
            }
        }

        Id userId = UserInfo.getUserId();
        System.debug(LoggingLevel.DEBUG, '*****Collab_CTRL_Referral.Collab_CTRL_Referral userId: ' + userId);
        if (String.isBlank(this.collaborativeRecord.Id) && !String.isBlank(userId)) {

            List<User> activeUsers = [SELECT AccountId, Name FROM User WHERE Id = :userId];
            System.debug(LoggingLevel.DEBUG, '*****Collab_CTRL_Referral.Collab_CTRL_Referral activeUsers: ' + activeUsers);
            if (!activeUsers.isEmpty() && !String.isBlank(activeUsers[0].AccountId)) {

                List<Collab_Setting__mdt> collabs = [SELECT Id, Account_Id__c, DeveloperName, New_Referral_Owner_Id__c, Eligibility_Report_URL__c FROM Collab_Setting__mdt WHERE Account_Id__c = :activeUsers[0].AccountId];
                System.debug(LoggingLevel.DEBUG, '*****Collab_CTRL_Referral.Collab_CTRL_Referral User Collab: ' + collabs);
                if (!collabs.isEmpty()) {
                    this.collaborativeRecord = collabs[0];
                }
            }
            else if (!UserInfo.getUserName().containsIgnoreCase('referral')) {

                // Valid SF user but no associated collab so just grab a collab for relating to family
                List<Collab_Setting__mdt> collabs = [SELECT Id, Account_Id__c, DeveloperName, New_Referral_Owner_Id__c, Eligibility_Report_URL__c FROM Collab_Setting__mdt LIMIT 1];
                System.debug(LoggingLevel.DEBUG, '*****Collab_CTRL_Referral.Collab_CTRL_Referral Defalt Collab: ' + collabs);
                if (!collabs.isEmpty()) {
                    this.collaborativeRecord = collabs[0];
                }
            }
        }

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
        else {
            
            // Insert empty rows into contacts datatable
            AddMoreEmptyRowsToContacts();
        }
    }   
    
    private void QueueMergeRecord(Id masterRecord, Id mergeRecord) {

        // Setup Steps
        //
        //  1) Need to create this report in Mass Merge Reports
        //  2) Merge Metric created automatically in SF need to change owner to referral User if Possible
        //      otherwise let this run to create referral User created merge metric and then delete the other one
        //
        String mergeMetricName = 'Merge Rule Pending Merge Public Referral';
        List<c501mm__C501_Merge_Metric__c> mergeMetrics = Database.Query('SELECT Id, c501mm__AutoMerge_Percentage__c FROM c501mm__C501_Merge_Metric__c WHERE Name = \'' + mergeMetricName + '\'');

        if (mergeMetrics.isEmpty()) {

            mergeMetrics.add( new c501mm__C501_Merge_Metric__c (
                Name = (Test.isRunningTest() ? ('TESTDATA ' + mergeMetricName) : mergeMetricName),
                c501mm__Confidence__c = 90.0,
                c501mm__AutoMerge_Percentage__c = 100.0,
                c501mm__AutoMerge_Objects__c = 'Account',
                c501mm__Enable_Contact_Merge_Discovery__c = false,
                c501mm__Enable_Account_Merge_Discovery__c = false,
                c501mm__Source_Report__c = 'Merge_Rule_Pending_Merge_Public_Referral',
                c501mm__Source_Object__c = 'Account',
                c501mm__Source_Object_Account_Id__c = 'Id',
                c501mm__Source_Object_Contact_Id__c = 'Id',
                c501mm__Description__c = mergeMetricName,
                c501mm__Unique_Id__c = 'Merge_Rule_Pending_Merge_Public_Referral'
            ));

            insert mergeMetrics;
        }

        insert new c501mm__C501_Account_Merge__c(
            c501mm__Unique_Id__c = mergeMetricName + masterRecord + mergeRecord,
            c501mm__Merge_Confidence__c = mergeMetrics[0].c501mm__AutoMerge_Percentage__c,
            c501mm__Account__c = masterRecord,
            c501mm__Merge_Target_Account__c = mergeRecord,
            c501mm__Merge_Metric__c = mergeMetrics[0].Id
        );

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

        if (this.contactRecords.isEmpty() || String.isBlank(this.contactRecords[0].LastName)) {
            return null;
        }
        
        try {

            // NPSP - Create Contact first which will create the Household
            //
            Boolean updateAccountOwner = false;
            Id householdId = this.accountRecord.Id;

            if (String.isBlank(householdId)) {
                        
                this.accountRecord.Name = this.contactRecords[0].LastName + ' Household';
                this.accountRecord.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'HH_Account' LIMIT 1].Id;
                insert this.accountRecord;

                householdId = this.accountRecord.Id;

                List<Contact> insertContacts = new List<Contact>();
                for (Contact contactRecord :this.contactRecords) {
        
                    // Save the Referral fields on the Contact for future delegation
                    contactRecord.Referral_Collab_Id__c = this.collaborativeRecord.Account_Id__c;
                    contactRecord.npe01__PreferredPhone__c = 'Mobile';

                    if (!UserInfo.getUserName().containsIgnoreCase('referral')) {
                        contactRecord.AccountId = householdId;
                        contactRecord.Referral_OwnerId__c = UserInfo.getUserId();
                    }
                    else {
                        contactRecord.C501_Swap_Household_Id__c = householdId;
                        contactRecord.Referral_OwnerId__c = this.collaborativeRecord.New_Referral_Owner_Id__c;
                    }

                    insertContacts.add(contactRecord);
                }

                if (!insertContacts.isEmpty()) {
                    insert insertContacts;
                }
            }
            else {
                
                update this.accountRecord;
            }

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

        if (UserInfo.getUserName().containsIgnoreCase('referral')) {
            Pagereference pageRef = new Pagereference('/referral/Collab_ReferralSubmitted');
            return pageRef;
        }

        idRedirect = this.accountRecord.Id;
        
        // trigger our redirect component to redirect using javascript.
        redirect = true;

        return null;
    }
    
    // user wants to close this page
    public virtual PageReference Cancel() {

        return null;
    }

    global virtual void AddMoreEmptyRowsToContacts() {
        try {
            if (this.contactRecords == null) return;

            for (integer i = 0; i < cEmptyContactRecords; i++) { 
                Contact contactRecord = new Contact();
                contactRecord.AccountId = this.accountRecord.Id;
                contactRecord.RecordTypeId = '0121U000000WxDnQAK';
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