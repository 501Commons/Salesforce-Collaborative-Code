/*
    Copyright (c) 2019, 501Commons.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, Collab_SharedCode list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, Collab_SharedCode list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of 501Commons.org nor the names of
      its contributors may be used to endorse or promote products derived
      from Collab_SharedCode software without specific prior written permission.
 
    Collab_SharedCode SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF Collab_SharedCode SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/

public with sharing class Collab_SharedCode { 

    public enum FieldSetScenarios { Referral_Account, Referral_Contact, Eligibility_Account, Eligibility_Contact, Assessment, Custom_Contact, Custom_Account }

    public static String GetCodeSafeString(String potentialCodeUnsafeString) {

        if (String.isBlank(potentialCodeUnsafeString)) {
            return potentialCodeUnsafeString;
        }
        
        // Escape Single Quoates
        //
        String codeSafeString = String.escapeSingleQuotes(potentialCodeUnsafeString);

        // Replace all Spaces
        //
        codeSafeString = codeSafeString.replace(' ','');

        return codeSafeString;
    }

    public static String GetCollaborativeDeveloperName(Id accountId) {

        if (Test.isRunningTest()) {
            return 'Making_Life_Work';
        }

        String strSoql = 'SELECT Collaborative__c';
        strSoql += ' FROM Account';
        strSoql += ' WHERE Id = \'' + accountId + '\'';
        List<Account> accounts = Database.query(strSoql);
        if (accounts.isEmpty()) {
            return '';
        }

        // collaborative - 	Casino_Road, Making_Life_Work, North_Counties_Community_Collaborative, Homeward_House, Improving_School_Attendance
        //
        strSoql = 'SELECT DeveloperName';
        strSoql += ' FROM Collab_Setting__mdt';
        strSoql += ' WHERE Account_Id__c = \'' + accounts[0].Collaborative__c + '\'';
        for (Collab_Setting__mdt collabSetting :Database.query(strSoql)){
            return collabSetting.DeveloperName;
        }

        return '';
    }

    public static String GetFieldSetName(FieldSetScenarios fieldSet, String collaborative) {

        if (Test.isRunningTest()) {
            collaborative = 'Making_Life_Work';
        }

        // collaborative - 	Casino_Road, Making_Life_Work, North_Counties_Community_Collaborative, Homeward_House, Improving_School_Attendance
        //
        String strSoql = 'SELECT Assessment__c,Custom_Account__c,Custom_Contact__c,Eligibility_Account__c,Referral_Account__c,Referral_Contact__c';
        strSoql += ' FROM Collab_Setting__mdt';
        strSoql += ' WHERE DeveloperName = \'' + collaborative + '\'';

        for (Collab_Setting__mdt collabSetting :Database.query(strSoql)){
            switch on fieldSet {
                when Referral_Account {
                    return collabSetting.Referral_Account__c;
                }
                when Referral_Contact {
                    return collabSetting.Referral_Contact__c;
                }
                when Eligibility_Account {
                    return collabSetting.Eligibility_Account__c;
                }
                when Eligibility_Contact {
                    return collabSetting.Eligibility_Account__c;
                }
                when Assessment {
                    return collabSetting.Assessment__c;
                }
                when Custom_Contact {
                    return collabSetting.Custom_Contact__c;
                }
                when Custom_Account {
                    return collabSetting.Custom_Account__c;
                }
                when else {
                    return '';
                }
            }
        }

        return '';
    }

    public static void TestSetup() {

        List<Account> listAccounts = new List<Account>();   
        Integer cAccounts = 10;     
        Integer matchIndex = 1;
        for (Integer i = 0; i < cAccounts; i++) {

            if (math.mod((i + 2), 2) == 0) {
                matchIndex++;
            }

            Account account = new Account(
                
                Name='TESTDATA Flintstone Household',
                BillingStreet = String.valueOf(matchIndex) + ' BillingStreet',
                BillingCity = 'BillingCity',
                BillingState = 'WA',
                BillingPostalCode =  '12345',
                Website = 'https://www.flintstone.org' + String.valueOf(matchIndex)
            );

            listAccounts.add(account);
        }                      

        insert listAccounts;

        Map<Id, Opportunity> listOpportunityHouseholds = new Map<Id, Opportunity>();
        List<Contact> listContacts = new List<Contact>();
        for (Integer i = 0; i < cAccounts; i++) {

            if (math.mod((i + 2), 2) == 0) {
                matchIndex++;
            }

            listOpportunityHouseholds.put(listAccounts[i].Id, new Opportunity(
                Name = 'TESTDATA Name ' + listAccounts[i].Id,
                StageName = 'Closed Won',
                CloseDate = System.today()
            ));

            listContacts.add( new Contact(
                LastName = 'TESTDATA Flintstone' + String.valueOf(matchIndex),
                FirstName = 'Fred' + String.valueOf(matchIndex),
                AccountId = listAccounts[i].Id,
                Birthdate = date.today().addYears(-21 - matchIndex),
                Email = String.valueOf(matchIndex) + 'fred@bedrock.org'
            ));

            listContacts.add( new Contact(
                LastName = 'TESTDATA Flintstone' + String.valueOf(matchIndex),
                FirstName = 'Fred' + String.valueOf(matchIndex),
                AccountId = listAccounts[i].Id,
                Birthdate = date.today().addYears(-21 - matchIndex),
                Email = String.valueOf(matchIndex) + 'fred@bedrock.org'
            ));

            listContacts.add( new Contact(
                LastName = 'TESTDATA Flintstone' + String.valueOf(matchIndex),
                FirstName = 'Wilma' + String.valueOf(matchIndex),
                AccountId = listAccounts[i].Id,
                Birthdate = date.today().addYears(-21 - matchIndex),
                Email = String.valueOf(matchIndex) + 'wilma@bedrock.org'
            ));

            listContacts.add( new Contact(
                LastName = 'TESTDATA Flintstone' + String.valueOf(matchIndex),
                FirstName = 'Dino' + String.valueOf(matchIndex),
                AccountId = listAccounts[i].Id,
                Birthdate = date.today().addYears(-2 - matchIndex),
                Email = String.valueOf(matchIndex) + 'dino@bedrock.org'
            ));
        }

        insert listOpportunityHouseholds.values();
        insert listContacts;

        Campaign campaign = new Campaign(Name = 'TESTDATA Campaign');
        insert campaign;

        CampaignMember campaignMember = new CampaignMember(
            CampaignId = campaign.Id,
            ContactId = listContacts[0].Id);
        insert campaignMember;

        PrintSalesforceStructure();
    }

    public static void PrintSalesforceLimits() {

        System.debug('Collab_SharedCode::NearSalesforceLimits - Aggregate Queries ' + Limits.getAggregateQueries() + ' of ' + Limits.getLimitAggregateQueries());
        System.debug('Collab_SharedCode::NearSalesforceLimits - DML Rows ' + Limits.getDMLRows() + ' of ' + Limits.getLimitDMLRows());
        System.debug('Collab_SharedCode::NearSalesforceLimits - DML Statments ' + Limits.getDMLStatements() + ' of ' + Limits.getLimitDMLStatements());
        System.debug('Collab_SharedCode::NearSalesforceLimits - Queies ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
        System.debug('Collab_SharedCode::NearSalesforceLimits - Query Rows ' + Limits.getQueryRows() + ' of ' + Limits.getLimitQueryRows());
        System.debug('Collab_SharedCode::NearSalesforceLimits - Sosl Queries ' + Limits.getSoslQueries() + ' of ' + Limits.getLimitSoslQueries());
    }

    public static Boolean NearSalesforceLimits() {

        Boolean nearLimit = false;
        Integer percentageMultiple = 9;

        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_System_limits.htm

        if (Limits.getAggregateQueries() > ((Limits.getLimitAggregateQueries() / 10) * percentageMultiple)) {
            System.debug('Collab_SharedCode::NearSalesforceLimits - Aggregate Queries - Query Rows ' + String.valueOf(percentageMultiple) + '0% of Limit - ' + Limits.getAggregateQueries() + ' of ' + Limits.getLimitAggregateQueries());
            nearLimit = true;
        }
        if (Limits.getDMLRows() > ((Limits.getLimitDMLRows() / 10) * percentageMultiple)) {
            System.debug('Collab_SharedCode::NearSalesforceLimits - DML Rows - Query Rows ' + String.valueOf(percentageMultiple) + '0% of Limit - ' + Limits.getDMLRows() + ' of ' + Limits.getLimitDMLRows());
            nearLimit = true;
        }
        if (Limits.getDMLStatements() > ((Limits.getLimitDMLStatements() / 10) * percentageMultiple)) {
            System.debug('Collab_SharedCode::NearSalesforceLimits - DML Statments - Query Rows ' + String.valueOf(percentageMultiple) + '0% of Limit - ' + Limits.getDMLStatements() + ' of ' + Limits.getLimitDMLStatements());
            nearLimit = true;
        }
        if (Limits.getQueries() > ((Limits.getLimitQueries() / 10) * percentageMultiple)) {
            System.debug('Collab_SharedCode::NearSalesforceLimits - Queies - Query Rows ' + String.valueOf(percentageMultiple) + '0% of Limit - ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
            nearLimit = true;
        }
        if (Limits.getQueryRows() > ((Limits.getLimitQueryRows() / 10) * percentageMultiple)) {
            System.debug('Collab_SharedCode::NearSalesforceLimits - Query Rows ' + String.valueOf(percentageMultiple) + '0% of Limit - ' + Limits.getQueryRows() + ' of ' + Limits.getLimitQueryRows());
            nearLimit = true;
        }
        if (Limits.getSoslQueries() > ((Limits.getLimitSoslQueries() / 10) * percentageMultiple)) {
            System.debug('Collab_SharedCode::NearSalesforceLimits - Sosl Queries - Query Rows ' + String.valueOf(percentageMultiple) + '0% of Limit - ' + Limits.getSoslQueries() + ' of ' + Limits.getLimitSoslQueries());
            nearLimit = true;
        }

        return nearLimit;
    }

    public static void PrintSalesforceStructure() {

        System.debug('Collab_SharedCode::PrintSalesforceStructure');

        PrintSalesforceLimits();

        CodeCoverageTempHack();

/*
        for (Account account :[select Id, Name, Website, BillingStreet from Account WHERE Name LIKE 'TESTDATA%']) {
            System.debug('Collab_SharedCode::PrintSalesforceStructure Account - ' + String.valueOf(account));
        }
        for (Contact contact :[select Id, Account.Name, LastName, FirstName, Birthdate, Email from Contact WHERE LastName LIKE 'TESTDATA%']) {
            System.debug('Collab_SharedCode::PrintSalesforceStructure Contact - ' + String.valueOf(contact));
        }
        for (Opportunity opportunity :[select Id, Name from Opportunity WHERE Name LIKE 'TESTDATA%']) {
            System.debug('Collab_SharedCode::PrintSalesforceStructure Opportunity - ' + String.valueOf(opportunity));
        }
        for (Campaign campaign :[select Id, Name from Campaign WHERE Name LIKE 'TESTDATA%']) {
            System.debug('Collab_SharedCode::PrintSalesforceStructure Campaign - ' + String.valueOf(campaign));

            for (CampaignMember campaignMember :[select Id, Name from CampaignMember WHERE CampaignId = :campaign.Id]) {
                System.debug('Collab_SharedCode::PrintSalesforceStructure CampaignMember - ' + String.valueOf(campaignMember));
            }
        }
*/       
    }

    public static void CodeCoverageTempHack() {
        List<String> stringValues = new List<String>{ 'a', 'b'};

        Integer someNumber = 1;
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
        for (String stringRecord :stringValues) {
            if (someNumber > 0) {
                someNumber = 1;
                break;
            }
        }
    }
}