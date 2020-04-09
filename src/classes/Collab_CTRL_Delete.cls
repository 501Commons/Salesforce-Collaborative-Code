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

global virtual with sharing class Collab_CTRL_Delete {

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

    // constructor
    global Collab_CTRL_Delete() {
        System.debug(LoggingLevel.DEBUG, 'Collab_CTRL_Delete::Collab_CTRL_Delete');
        new Collab_CTRL_Delete(null);
    }

    global Collab_CTRL_Delete(ApexPages.StandardController controller) {

        redirect = false;

        Account accountRecord = (Account)controller.getRecord();
    }
}