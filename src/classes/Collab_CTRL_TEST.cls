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

//
// GENERIC CLASS - modify of the C501_MassCollab_SharedCode_[Object].cls classes then copy to the all the others
//
//      1) Make changes to the class
//      2) Copy/Paste entire class to all other C501_MassCollab_SharedCode_[Object].cls classes
//      3) Search and replace all [Object] references with [Target Object]
//
//  This is a workaround for Generic classes since <T> - Templating not supported in Apex
//

@isTest
class Collab_CTRL_TEST {

    //==================== TEST METHOD(s) ======================================


    @isTest(SeeAllData='false')
    static void NewGoalTest() {

      Test.StartTest();

      Collab_CTRL_Goal ctrlGoal = new Collab_CTRL_Goal(new Apexpages.StandardController(new Collaborative_Goal__c()));
  
      // test the save!
      ctrlGoal.SaveGoal();

      ctrlGoal.goalRecord.Name = 'New Goal';

      ctrlGoal.SaveGoal();      
      ctrlGoal.SaveAndCloseGoal();   

      Test.StopTest();
    }

    @isTest(SeeAllData='false')
    static void NewPartnerTest() {

      Test.StartTest();

      Collab_CTRL_Partner ctrlPartner = new Collab_CTRL_Partner(new Apexpages.StandardController(new Account()));
  
      // test the save!
      ctrlPartner.SavePartner();

      ctrlPartner.accountRecord.Name = 'New Partner';

      ctrlPartner.SavePartner();      
      ctrlPartner.SaveAndClosePartner();   

      Test.StopTest();
    }

    @isTest(SeeAllData='true')
    static void NewContactTest() {

      Collab_SharedCode.TestSetup();

      Account objRecord = [SELECT Id FROM Account WHERE Name LIKE '%TESTDATA%' ORDER BY Id ASC LIMIT 1];
      System.Debug('NewContactTest - Id: ' + objRecord.Id);

      Test.StartTest();

      // Referral
      //
//      System.currentPageReference().getParameters().put('collab', 'Casino_Road');
      Collab_CTRL_Referral ctrlReferral = new Collab_CTRL_Referral(new Apexpages.StandardController(objRecord));
  
      // test the save!
      ctrlReferral.SaveReferral();

      System.debug('Collab_CTRL_TEST::NewContactTest' + ctrlReferral.strSaveResults);
      //System.Assert(ctrl.strSaveResults.startsWith('Error'));

      ctrlReferral.SaveReferral();      
      ctrlReferral.SaveAndCloseReferral();   

      Test.StopTest();
    }

    @isTest(SeeAllData='true')
    static void EditContactTest() {

      Collab_SharedCode.TestSetup();

      Account objRecord = [SELECT Id FROM Account WHERE Name LIKE '%TESTDATA%' ORDER BY Id ASC LIMIT 1];
      System.Debug('EditContactTest - contactId: ' + objRecord.Id);

      Test.StartTest();

      // Referral
      //
//      System.currentPageReference().getParameters().put('collab', 'Casino_Road');
      Collab_CTRL_Referral ctrlReferral = new Collab_CTRL_Referral(new Apexpages.StandardController(objRecord));

      // test the save!
      ctrlReferral.SaveReferral();

      System.debug('Collab_CTRL_TEST::NewContactTest' + ctrlReferral.strSaveResults);
      //System.Assert(ctrl.strSaveResults.startsWith('Error'));

      ctrlReferral.SaveReferral();      
      ctrlReferral.SaveAndCloseReferral();   

      Test.StopTest();
    }

    @isTest(SeeAllData='true')
    static void testPageMessagesController() {

      Collab_SharedCode.TestSetup();

      Test.StartTest();

      ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING,'warning'));
      ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'info'));
      ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL,'fatal'));
      ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'error'));
      ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM,'confirm'));

      Collab_UTIL_PageMessages_CTRL controller = new Collab_UTIL_PageMessages_CTRL();
      List<Collab_UTIL_PageMessages_CTRL.Message> messages = controller.getPageMessages();

      System.assertEquals(5, messages.size(), 'There should be 5 messages on the page.');

      System.assertEquals(Label.Collab_PageMessagesWarning, messages[0].getSeverityLabel(), 'The label should be WARNING.');
      System.assertEquals('', messages[1].getSeverityLabel(), 'The label should be INFO.');
      System.assertEquals(Label.Collab_PageMessagesFatal, messages[2].getSeverityLabel(), 'The label should be FATAL.');
      System.assertEquals(Label.Collab_PageMessagesError, messages[3].getSeverityLabel(), 'The label should be ERROR.');
      System.assertEquals(Label.Collab_PageMessagesConfirm, messages[4].getSeverityLabel(), 'The label should be CONFIRM.');

      System.assertEquals('warning', messages[0].getSeverityTheme(), 'The theme should be warning.');
      System.assertEquals('info', messages[1].getSeverityTheme(), 'The theme should be info.');
      System.assertEquals('error', messages[2].getSeverityTheme(), 'The theme should be fatal.');
      System.assertEquals('error', messages[3].getSeverityTheme(), 'The theme should be error.');
      System.assertEquals('success', messages[4].getSeverityTheme(), 'The theme should be confirm.');

      Test.StopTest();
    }
}