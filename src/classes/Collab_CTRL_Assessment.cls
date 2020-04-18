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

global virtual with sharing class Collab_CTRL_Assessment {

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

    public Assessment__c assessmentRecord {
        get {
            if (assessmentRecord == null) {
                assessmentRecord = new Assessment__c();
            }

            return assessmentRecord;
        }
        set;
    }

    public Assessment__c assessmentRecordEarlyChildhood {
        get {
            if (assessmentRecordEarlyChildhood == null) {
                assessmentRecordEarlyChildhood = new Assessment__c();
            }

            return assessmentRecordEarlyChildhood;
        }
        set;
    }

    public Assessment__c assessmentRecordEconomicAssets {
        get {
            if (assessmentRecordEconomicAssets == null) {
                assessmentRecordEconomicAssets = new Assessment__c();
            }

            return assessmentRecordEconomicAssets;
        }
        set;
    }

    public Assessment__c assessmentRecordHealthWellBeing {
        get {
            if (assessmentRecordHealthWellBeing == null) {
                assessmentRecordHealthWellBeing = new Assessment__c();
            }

            return assessmentRecordHealthWellBeing;
        }
        set;
    }

    public Assessment__c assessmentRecordPostSecondaryEmployment {
        get {
            if (assessmentRecordPostSecondaryEmployment == null) {
                assessmentRecordPostSecondaryEmployment = new Assessment__c();
            }

            return assessmentRecordPostSecondaryEmployment;
        }
        set;
    }

    public Assessment__c assessmentRecordSocialCapital {
        get {
            if (assessmentRecordSocialCapital == null) {
                assessmentRecordSocialCapital = new Assessment__c();
            }

            return assessmentRecordSocialCapital;
        }
        set;
    }

    // constructor
    global Collab_CTRL_Assessment() {
        System.debug(LoggingLevel.DEBUG, 'Collab_CTRL_Assessment::Collab_CTRL_Assessment');
        new Collab_CTRL_Assessment(null);
    }

    global Collab_CTRL_Assessment(ApexPages.StandardController controller) {

        redirect = false;

        if (controller.getRecord().getSObjectType() == Schema.Account.getSObjectType()) {
            Account accountControllerRecord = (Account)controller.getRecord();
            System.debug('****Collab_CTRL_Assessment Controller for Account: ' + accountControllerRecord);
            this.assessmentRecord.Account__c = accountControllerRecord.Id;
        }
        else {
            Assessment__c assessmentControllerRecord = (Assessment__c)controller.getRecord();
            this.assessmentRecord = [SELECT Id, Name, Account__c, Domain__c FROM Assessment__c WHERE Id = :assessmentControllerRecord.Id LIMIT 1];
            System.debug('****Collab_CTRL_Assessment Controller for Assessment: ' + this.assessmentRecord);
        }

        this.obj = (sObject)this.assessmentRecord;

        if (Test.isRunningTest()) {
            this.collaborative = 'Making_Life_Work';
        }

        if (String.isBlank(this.collaborative)) {
            this.collaborative = Collab_SharedCode.GetCollaborativeDeveloperName(this.assessmentRecord.Account__c);
        }

        // Assessment - Get list of fields from Assessment fieldset
        List<String> listAssessmentFields = new List<String>();
        for (Schema.FieldSetMember f : this.getAssessmentFields()) {
            listAssessmentFields.add(f.getFieldPath());
        }

        if (this.getAssessmentFieldsEarlyChildhood() <> null) {
            for (Schema.FieldSetMember f : this.getAssessmentFieldsEarlyChildhood()) {
                if (!listAssessmentFields.contains(f.getFieldPath())) {
                    listAssessmentFields.add(f.getFieldPath());
                }
            }
        }

        if (this.getAssessmentFieldsEconomicAssets() <> null) {
            for (Schema.FieldSetMember f : this.getAssessmentFieldsEconomicAssets()) {
                if (!listAssessmentFields.contains(f.getFieldPath())) {
                    listAssessmentFields.add(f.getFieldPath());
                }
            }
        }

        if (this.getAssessmentFieldsHealthWellBeing() <> null) {
            for (Schema.FieldSetMember f : this.getAssessmentFieldsHealthWellBeing()) {
                if (!listAssessmentFields.contains(f.getFieldPath())) {
                    listAssessmentFields.add(f.getFieldPath());
                }
            }
        }

        if (this.getAssessmentFieldsPostSecondaryEmployment() <> null) {
            for (Schema.FieldSetMember f : this.getAssessmentFieldsPostSecondaryEmployment()) {
                if (!listAssessmentFields.contains(f.getFieldPath())) {
                    listAssessmentFields.add(f.getFieldPath());
                }
            }
        }

        if (this.getAssessmentFieldsSocialCapital() <> null) {
            for (Schema.FieldSetMember f : this.getAssessmentFieldsSocialCapital()) {
                if (!listAssessmentFields.contains(f.getFieldPath())) {
                    listAssessmentFields.add(f.getFieldPath());
                }
            }
        }

        // Assessment - Required fields
        if (!listAssessmentFields.contains('Id')) {
            listAssessmentFields.add('Id');
        }

        if (!listAssessmentFields.contains('Name')) {
            listAssessmentFields.add('Name');
        }

        if (!listAssessmentFields.contains('Account__c')) {
            listAssessmentFields.add('Account__c');
        }

        if (!listAssessmentFields.contains('Domain__c')) {
            listAssessmentFields.add('Domain__c');
        }

        if (!String.isBlank(this.assessmentRecord.Id)) {

            String strSoql = 'SELECT ' + String.join(listAssessmentFields, ',');
            strSoql += ' FROM Assessment__c WHERE Id = \'' + this.assessmentRecord.Id + '\'';

            System.debug('Collab_CTRL_Assessment::Collab_CTRL_Assessment soql: ' + strSoql);
            for (Assessment__c assessmentExisting :Database.query(strSoql)) {

                this.assessmentRecord = assessmentExisting;
                System.debug('Collab_CTRL_Assessment::Collab_CTRL_Assessment query assessment record: ' + this.assessmentRecord);

                if (this.assessmentRecord.Domain__c == Collab_Sharedcode.Domains.Early_Childhood.name()) {
                    this.assessmentRecordEarlyChildhood = this.assessmentRecord;
                }
                else if (this.assessmentRecord.Domain__c == Collab_Sharedcode.Domains.Economic_Assets.name()) {
                    this.assessmentRecordEconomicAssets = this.assessmentRecord;
                }
                else if (this.assessmentRecord.Domain__c == Collab_Sharedcode.Domains.Health_Well_Being.name()) {
                    this.assessmentRecordHealthWellBeing = this.assessmentRecord;
                }
                else if (this.assessmentRecord.Domain__c == Collab_Sharedcode.Domains.Post_Secondary_Employment.name()) {
                    this.assessmentRecordPostSecondaryEmployment = this.assessmentRecord;
                }
                else if (this.assessmentRecord.Domain__c == Collab_Sharedcode.Domains.Social_Capital.name()) {
                    this.assessmentRecordSocialCapital = this.assessmentRecord;
                }
                
                break;
            }
        }
    }   
    
    // holds the currently select Family Member Id
    public ID familyMemberId { get; set; }

    // the list of Substitutes Shifts to put in the dropdown
    public list<SelectOption> listFamilyMembers {
        get {
            if (listFamilyMembers == null && !String.isBlank(this.assessmentRecord.Account__c)) {

                listFamilyMembers = new List<SelectOption>{ new SelectOption('', '') };

                for (Contact familyMember :[SELECT Id, Name FROM Contact WHERE AccountId = :this.assessmentRecord.Account__c]) {
                    listFamilyMembers.add(new SelectOption(familyMember.Id, familyMember.Name));
                }
            }

            return listFamilyMembers;
        }
           
        set;
    }
    
    // getter - reference in Visualforce as AssessmentFields
    public List<Schema.FieldSetMember> getAssessmentFields() {
        return fieldSetAssessmentActive('');
    }

    public List<Schema.FieldSetMember> fieldSetAssessmentActive(String domain) {
        String fieldSetNameMetadata = Collab_SharedCode.GetFieldSetName(Collab_SharedCode.FieldSetScenarios.Assessment, this.collaborative) + domain;
        for (String fieldSetName :Schema.SObjectType.Assessment__c.fieldSets.getMap().keySet()) {

            // Check for custom fields set
            if (fieldSetName.equalsIgnoreCase(fieldSetNameMetadata)) {
                return Schema.SObjectType.Assessment__c.fieldSets.getMap().get(fieldSetNameMetadata).getFields();
            }
        }

        return null;
    }

    // getter - reference in Visualforce as AssessmentFields Early Childhood
    public List<Schema.FieldSetMember> getAssessmentFieldsEarlyChildhood() {

        if (!String.isBlank(this.assessmentRecord.Id) && this.assessmentRecord.Domain__c <> Collab_Sharedcode.Domains.Early_Childhood.name()) {
            return null;
        }

        return fieldSetAssessmentActive('_' + Collab_Sharedcode.Domains.Early_Childhood.name());
    }

    // getter - reference in Visualforce as AssessmentFields Economic Assets
    public List<Schema.FieldSetMember> getAssessmentFieldsEconomicAssets() {

        if (!String.isBlank(this.assessmentRecord.Id) && this.assessmentRecord.Domain__c <> Collab_Sharedcode.Domains.Economic_Assets.name()) {
            return null;
        }

        return fieldSetAssessmentActive('_' + Collab_Sharedcode.Domains.Economic_Assets.name());
    }

    // getter - reference in Visualforce as AssessmentFields Health Well-Being
    public List<Schema.FieldSetMember> getAssessmentFieldsHealthWellBeing() {

        if (!String.isBlank(this.assessmentRecord.Id) && this.assessmentRecord.Domain__c <> Collab_Sharedcode.Domains.Health_Well_Being.name()) {
            return null;
        }

        return fieldSetAssessmentActive('_' + Collab_Sharedcode.Domains.Health_Well_Being.name());
    }

    // getter - reference in Visualforce as AssessmentFields Post-Secondary & Employment
    public List<Schema.FieldSetMember> getAssessmentFieldsPostSecondaryEmployment() {

        if (!String.isBlank(this.assessmentRecord.Id) && this.assessmentRecord.Domain__c <> Collab_Sharedcode.Domains.Post_Secondary_Employment.name()) {
            return null;
        }

        return fieldSetAssessmentActive('_' + Collab_Sharedcode.Domains.Post_Secondary_Employment.name());
    }

    // getter - reference in Visualforce as AssessmentFields Social Capital
    public List<Schema.FieldSetMember> getAssessmentFieldsSocialCapital() {

        if (!String.isBlank(this.assessmentRecord.Id) && this.assessmentRecord.Domain__c <> Collab_Sharedcode.Domains.Social_Capital.name()) {
            return null;
        }

        return fieldSetAssessmentActive('_' + Collab_Sharedcode.Domains.Social_Capital);
    }

    // status string for reporting the results of saving.
    public String strSaveResults { get; set; }

    //save the Contacts created or modified
    public virtual PageReference SaveAssessment() {
        
        strSaveResults = null;
        
        try {

            if (!String.isBlank(this.familyMemberId)) {
                this.assessmentRecord.Family_Member__c = this.familyMemberId;
            }

            if (String.isBlank(this.assessmentRecord.Id)) {

                // Check Early Childhood Fields
                this.assessmentRecord.Domain__c = Collab_Sharedcode.Domains.Early_Childhood.name();
                if (this.domainFieldValid(this.assessmentRecord.Domain__c)) {
                    System.debug('**** domainFieldValid - ' + this.assessmentRecord.Domain__c);
                    this.assessmentRecord.Id = null;
                    insert this.assessmentRecord;
                    this.assessmentRecordEarlyChildhood.Id = this.assessmentRecord.Id;
                    update this.assessmentRecordEarlyChildhood;
                }

                // Check Economic Assets Fields
                this.assessmentRecord.Domain__c = Collab_Sharedcode.Domains.Economic_Assets.name();
                if (domainFieldValid(this.assessmentRecord.Domain__c)) {
                    System.debug('**** domainFieldValid - ' + this.assessmentRecord.Domain__c);
                    this.assessmentRecord.Id = null;
                    insert this.assessmentRecord;
                    this.assessmentRecordEconomicAssets.Id = this.assessmentRecord.Id;
                    update this.assessmentRecordEconomicAssets;
                }

                // Check Health Well-Being Fields
                this.assessmentRecord.Domain__c = Collab_Sharedcode.Domains.Health_Well_Being.name();
                if (this.domainFieldValid(this.assessmentRecord.Domain__c)) {
                    System.debug('**** domainFieldValid - ' + this.assessmentRecord.Domain__c);
                    this.assessmentRecord.Id = null;
                    insert this.assessmentRecord;
                    this.assessmentRecordHealthWellBeing.Id = this.assessmentRecord.Id;
                    update this.assessmentRecordHealthWellBeing;
                }

                // Check Post-Secondary Employment
                this.assessmentRecord.Domain__c = Collab_Sharedcode.Domains.Post_Secondary_Employment.name();
                if (this.domainFieldValid(this.assessmentRecord.Domain__c)) {
                    System.debug('**** domainFieldValid - ' + this.assessmentRecord.Domain__c);
                    this.assessmentRecord.Id = null;
                    insert this.assessmentRecord;
                    this.assessmentRecordPostSecondaryEmployment.Id = this.assessmentRecord.Id;
                    update this.assessmentRecordPostSecondaryEmployment;
                }

                // Check Social Capital
                this.assessmentRecord.Domain__c = Collab_Sharedcode.Domains.Social_Capital.name();
                if (this.domainFieldValid(this.assessmentRecord.Domain__c)) {
                    System.debug('**** domainFieldValid - ' + this.assessmentRecord.Domain__c);
                    this.assessmentRecord.Id = null;
                    insert this.assessmentRecord;
                    this.assessmentRecordSocialCapital.Id = this.assessmentRecord.Id;
                    update this.assessmentRecordSocialCapital;
                }
            }
            else {

                if (this.assessmentRecord.Domain__c == Collab_Sharedcode.Domains.Early_Childhood.name()) {
                    this.assessmentRecordEarlyChildhood.Id = this.assessmentRecord.Id;
                    update this.assessmentRecordEarlyChildhood;
                }
                else if (this.assessmentRecord.Domain__c == Collab_Sharedcode.Domains.Economic_Assets.name()) {
                    this.assessmentRecordEconomicAssets.Id = this.assessmentRecord.Id;
                    update this.assessmentRecordEconomicAssets;
                }
                else if (this.assessmentRecord.Domain__c == Collab_Sharedcode.Domains.Health_Well_Being.name()) {
                    this.assessmentRecordHealthWellBeing.Id = this.assessmentRecord.Id;
                    update this.assessmentRecordHealthWellBeing;
                }
                else if (this.assessmentRecord.Domain__c == Collab_Sharedcode.Domains.Post_Secondary_Employment.name()) {
                    this.assessmentRecordPostSecondaryEmployment.Id = this.assessmentRecord.Id;
                    update this.assessmentRecordPostSecondaryEmployment;
                }
                else if (this.assessmentRecord.Domain__c == Collab_Sharedcode.Domains.Social_Capital.name()) {
                    this.assessmentRecordSocialCapital.Id = this.assessmentRecord.Id;
                    update this.assessmentRecordSocialCapital;
                }

                update this.assessmentRecord;
            }

            return null;

        } catch (Exception e) {
            strSaveResults = Label.Collab_labelAssessmentErrorOnSave;
            ApexPages.addMessages(e); 
            return null;
        }
    }

    //save the Contacts modified, and then close the page.
    public virtual PageReference SaveAndCloseAssessment() {
        SaveAssessment();
        if (ApexPages.hasMessages(ApexPages.Severity.ERROR) ||
           ApexPages.hasMessages(ApexPages.Severity.FATAL) ||
            ApexPages.hasMessages(ApexPages.Severity.WARNING)) {
                return null; // don't close window.
        }
        return Cancel();    
    }

    // user wants to close this page
    public virtual PageReference Cancel() {
        idRedirect = this.assessmentRecord.Id;
        
        // trigger our redirect component to redirect using javascript.
        redirect = true;
        return null;
    }

    private Boolean domainFieldValid(String domain) {

        List<Schema.FieldSetMember> fieldSetMembers = null;
        Assessment__c assessmentRecordDomain = null;
        if (domain.equalsIgnoreCase(Collab_Sharedcode.Domains.Early_Childhood.name()) && this.getAssessmentFieldsEarlyChildhood() <> null) {
            fieldSetMembers = this.getAssessmentFieldsEarlyChildhood();
            assessmentRecordDomain = this.assessmentRecordEarlyChildhood;
        }
        else if (domain.equalsIgnoreCase(Collab_Sharedcode.Domains.Economic_Assets.name()) && this.getAssessmentFieldsEconomicAssets() <> null) {
            fieldSetMembers = this.getAssessmentFieldsEconomicAssets();
            assessmentRecordDomain = this.assessmentRecordEconomicAssets;
        }
        else if (domain.equalsIgnoreCase(Collab_Sharedcode.Domains.Health_Well_Being.name()) && this.getAssessmentFieldsHealthWellBeing() <> null) {
            fieldSetMembers = this.getAssessmentFieldsHealthWellBeing();
            assessmentRecordDomain = this.assessmentRecordHealthWellBeing;
        }
        else if (domain.equalsIgnoreCase(Collab_Sharedcode.Domains.Post_Secondary_Employment.name()) && this.getAssessmentFieldsPostSecondaryEmployment() <> null) {
            fieldSetMembers = this.getAssessmentFieldsPostSecondaryEmployment();
            assessmentRecordDomain = this.assessmentRecordPostSecondaryEmployment;
        }
        else if (domain.equalsIgnoreCase(Collab_Sharedcode.Domains.Social_Capital.name()) && this.getAssessmentFieldsSocialCapital() <> null) {
            fieldSetMembers = this.getAssessmentFieldsSocialCapital();
            assessmentRecordDomain = this.assessmentRecordSocialCapital;
        }

        if (fieldSetMembers <> null) {
            for (Schema.FieldSetMember fieldSetRecord : fieldSetMembers) {
                System.debug('****Collab_CTRL_Assessment:domainFieldValue ' + domain + ' - '  + fieldSetRecord.getFieldPath() + ' with value ' + assessmentRecordDomain.get(fieldSetRecord.getFieldPath()));
                if (!String.isBlank(String.valueOf(assessmentRecordDomain.get(fieldSetRecord.getFieldPath())))) {
                    return true;
                }
            }
        }

        return false;
    }
}