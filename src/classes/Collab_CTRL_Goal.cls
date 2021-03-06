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

global virtual with sharing class Collab_CTRL_Goal {

    public boolean redirect { get; private set; }
    public ID idRedirect { get; private set; }
    
    public Collaborative_Goal__c goalRecord {
        get {
            if (goalRecord == null) {
                goalRecord = new Collaborative_Goal__c();
            }

            return goalRecord;
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
    global Collab_CTRL_Goal() {
        System.debug(LoggingLevel.DEBUG, 'Collab_CTRL_Goal::Collab_CTRL_Goal');
        new Collab_CTRL_Goal(null);
    }

    global Collab_CTRL_Goal(ApexPages.StandardController controller) {

        System.debug(LoggingLevel.DEBUG, '*****Collab_CTRL_Goal.Collab_CTRL_Goal');
        redirect = false;

        if (Test.isRunningTest()) {

            List<Collab_Setting__mdt> collabs = [SELECT Id, Account_Id__c, DeveloperName FROM Collab_Setting__mdt LIMIT 1];
            if (!collabs.isEmpty()) {
                this.collaborativeRecord = collabs[0];
            }
        }

        if (String.isBlank(this.collaborativeRecord.Id)) {

            String collaborativeDeveloperName = System.currentPageReference().getParameters().get('collab');

            if (!String.isBlank(collaborativeDeveloperName)) {

                // Security Injection Checks
                collaborativeDeveloperName = Collab_SharedCode.GetCodeSafeString(collaborativeDeveloperName);
    
                List<Collab_Setting__mdt> collabs = [SELECT Id, Account_Id__c, DeveloperName FROM Collab_Setting__mdt WHERE DeveloperName = :collaborativeDeveloperName LIMIT 1];
                if (!collabs.isEmpty()) {
                    this.collaborativeRecord = collabs[0];
                }
            }
        }

        Id userId = UserInfo.getUserId();
        System.debug(LoggingLevel.DEBUG, '*****Collab_CTRL_Goal.Collab_CTRL_Goal userId: ' + userId);
        if (String.isBlank(this.collaborativeRecord.Id) && !String.isBlank(userId)) {

            List<User> activeUsers = [SELECT AccountId, Name FROM User WHERE Id = :userId];
            System.debug(LoggingLevel.DEBUG, '*****Collab_CTRL_Goal.Collab_CTRL_Goal activeUsers: ' + activeUsers);
            if (!activeUsers.isEmpty() && !String.isBlank(activeUsers[0].AccountId)) {

                List<Collab_Setting__mdt> collabs = [SELECT Id, Account_Id__c, DeveloperName FROM Collab_Setting__mdt WHERE Account_Id__c = :activeUsers[0].AccountId];
                System.debug(LoggingLevel.DEBUG, '*****Collab_CTRL_Goal.Collab_CTRL_Goal User Collab: ' + collabs);
                if (!collabs.isEmpty()) {
                    this.collaborativeRecord = collabs[0];
                }
            }
            else {

                // Valid SF user but no associated collab so just grab a collab for relating to family
                List<Collab_Setting__mdt> collabs = [SELECT Id, Account_Id__c, DeveloperName FROM Collab_Setting__mdt LIMIT 1];
                System.debug(LoggingLevel.DEBUG, '*****Collab_CTRL_Goal.Collab_CTRL_Goal Defalt Collab: ' + collabs);
                if (!collabs.isEmpty()) {
                    this.collaborativeRecord = collabs[0];
                }
            }
        }
    }   
    
    // status string for reporting the results of saving.
    public String strSaveResults { get; set; }

    //save the Contacts created or modified
    public virtual PageReference SaveGoal() {
        
        strSaveResults = null;

        try {

            Id householdId = this.goalRecord.Id;

            if (String.isBlank(this.goalRecord.Id) && !String.isBlank(this.goalRecord.Name)) {
                        
                this.goalRecord.Collaborative__c = this.collaborativeRecord.Account_Id__c;

                insert this.goalRecord;
            }

            return null;

        } catch (Exception e) {

            strSaveResults = Label.Collab_labelGoalErrorOnSave;
            ApexPages.addMessages(e); 

            return null;
        }
    }

    //save the Contacts modified, and then close the page.
    public virtual PageReference SaveAndCloseGoal() {

        SaveGoal();

        if (ApexPages.hasMessages(ApexPages.Severity.ERROR) ||
            ApexPages.hasMessages(ApexPages.Severity.FATAL) ||
            ApexPages.hasMessages(ApexPages.Severity.WARNING)) {
                return null; // don't close window.
        }

        idRedirect = this.goalRecord.Id;
        
        // trigger our redirect component to redirect using javascript.
        redirect = true;

        return null;
    }
    
    // user wants to close this page
    public virtual PageReference Cancel() {

        return null;
    }
}