/*
    Copyright (c) 2016, Salesforce.org
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
 
    THIS GroupFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS GroupFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/

public virtual with sharing class Collab_CTRL_Referral {

    private List<String> listStrFields;
    
    public boolean redirect { get; private set; }
    public ID idRedirect { get; private set; }
    
    public Contact contactRecord {
        get {
            if (contactRecord == null) {
                contactRecord = new Contact();
            }

            return contactRecord;
        }
        set;
    }

    // constructor
    public Collab_CTRL_Referral() {
        new Collab_CTRL_Referral(null);
    }

    public Collab_CTRL_Referral(ApexPages.StandardController controller) {

        System.debug('Collab_CTRL_Referral::Collab_CTRL_Referral Constructor');

        redirect = false;
        
        // Get list of fields FROM fieldset
        listStrFields = new List<String>();
        for (Schema.FieldSetMember f : this.getStandardFields()) {
            listStrFields.add(f.getFieldPath());
        }

        // Required fields
        if (!listStrFields.contains('Id')) {
            listStrFields.add('Id');
        }
        if (!listStrFields.contains('LastName')) {
            listStrFields.add('LastName');
        }

        this.contactRecord = (Contact)controller.getRecord();

        if (controller != null && this.contactRecord.Id != null) {
            System.debug('Collab_CTRL_Referral::Collab_CTRL_Referral getRecord: ' + this.contactRecord);
            System.debug('Collab_CTRL_Referral::Collab_CTRL_Referral getRecordId: ' + this.contactRecord.Id);

            String strSoql = 'SELECT ' + String.join(listStrFields, ',');
            strSoql += ' FROM Contact WHERE Id = \'' + this.contactRecord.Id + '\'';

            System.debug('Collab_CTRL_Referral::Collab_CTRL_Referral soql: ' + strSoql);

            for (Contact contactRecord :Database.query(strSoql)) {
                this.contactRecord = contactRecord;
                System.debug('Collab_CTRL_Referral::Collab_CTRL_Referral query record: ' + this.contactRecord);
                break;
            }
        }
        else {
            this.contactRecord = new Contact();
        }
    }   
    
    // getter - reference in Visualforce as StandardFields
    public List<Schema.FieldSetMember> getStandardFields() {
        return fieldSetStandardActive.getFields();
    }

    public Schema.FieldSet fieldSetStandardActive {
        get {

            Schema.FieldSet fieldSetCheck = SObjectType.Contact.FieldSets.C501_CCR_Referral_Contact;
            for (String fieldSetName :Schema.SObjectType.Contact.fieldSets.getMap().keySet()) {

                // Check for custom fields set
                if (fieldSetName.equals('Standard Information')) {
                    fieldSetCheck = Schema.SObjectType.Contact.fieldSets.getMap().get(fieldSetName);
                    break;
                }
            }

            return fieldSetCheck;
        }
        set;
    }

    // status string for reporting the results of saving.
    public String strSaveResults { get; set; }

    //save the Contacts created or modified
    public virtual PageReference SaveReferral() {
        
        strSaveResults = null;
        
        try {

            if (String.isBlank(contactRecord.Id)) {
                insert contactRecord;
            }
            else {
                update contactRecord;
            }

            // Create a Referral Service Record
            

            return null;

        } catch (Exception e) {
            strSaveResults = Label.CS_labelReferralErrorOnSave;
            ApexPages.addMessages(e); 
            return null;
        }
    }

    //save the Contacts modified, and then close the page.
    public virtual PageReference SaveAndCloseContact() {
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
        idRedirect = contactRecord.Id;
        
        // trigger our redirect component to redirect using javascript.
        redirect = true;
        return null;
    }
}