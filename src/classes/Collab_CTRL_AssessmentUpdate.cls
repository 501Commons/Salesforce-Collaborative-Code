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

global virtual with sharing class Collab_CTRL_AssessmentUpdate {

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

    // constructor
    global Collab_CTRL_AssessmentUpdate() {
        System.debug(LoggingLevel.DEBUG, 'Collab_CTRL_AssessmentUpdate::Collab_CTRL_AssessmentUpdate');
        new Collab_CTRL_Assessment(null);
    }

    global Collab_CTRL_AssessmentUpdate(ApexPages.StandardController controller) {

        redirect = false;

        this.assessmentRecord = (Assessment__c)controller.getRecord();
        if (String.isBlank(this.assessmentRecord.Id)) {
            return;
        }

        this.assessmentRecord = [SELECT Id, Account__c FROM Assessment__c WHERE Id = :this.assessmentRecord.Id LIMIT 1];
        this.obj = (sObject)this.assessmentRecord;

        if (String.isBlank(this.assessmentRecord.Account__c)) {
            return;
        }

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

        // Assessment - Required fields
        if (!listAssessmentFields.contains('Id')) {
            listAssessmentFields.add('Id');
        }

        if (!listAssessmentFields.contains('Name')) {
            listAssessmentFields.add('Name');
        }

        if (!String.isBlank(this.assessmentRecord.Id)) {

            String strSoql = 'SELECT ' + String.join(listAssessmentFields, ',');
            strSoql += ' FROM Assessment__c WHERE Id = \'' + this.assessmentRecord.Id + '\'';

            System.debug('Collab_CTRL_Assessment::Collab_CTRL_Assessment soql: ' + strSoql);
            for (Assessment__c assessmentExisting :Database.query(strSoql)) {
                this.assessmentRecord = assessmentExisting;
                System.debug('Collab_CTRL_Assessment::Collab_CTRL_Assessment query assessment record: ' + this.assessmentRecord);
                break;
            }
        }
    }   
    
    // getter - reference in Visualforce as AssessmentFields
    public List<Schema.FieldSetMember> getAssessmentFields() {
        return fieldSetAssessmentActive.getFields();
    }

    public Schema.FieldSet fieldSetAssessmentActive {
        get {

            String fieldSetNameMetadata = Collab_SharedCode.GetFieldSetName(Collab_SharedCode.FieldSetScenarios.Assessment, this.collaborative);
            for (String fieldSetName :Schema.SObjectType.Assessment__c.fieldSets.getMap().keySet()) {

                // Check for custom fields set
                if (fieldSetName.equalsIgnoreCase(fieldSetNameMetadata)) {
                    return Schema.SObjectType.Assessment__c.fieldSets.getMap().get(fieldSetNameMetadata);
                }
            }

            return null;
        }
        set;
    }

    // status string for reporting the results of saving.
    public String strSaveResults { get; set; }

    //save the Contacts created or modified
    public virtual PageReference SaveAssessment() {
        
        strSaveResults = null;
        
        try {
            
            if (String.isBlank(this.assessmentRecord.Id)) {

                // Set to REPLACE which is an NPSP key that means to rebuild name based on NPSP Household Settings
                this.assessmentRecord.Name = (String.isBlank(this.assessmentRecord.Name)) ? 'REPLACE' : this.assessmentRecord.Name;
                insert this.assessmentRecord;
            }
            else {
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
}