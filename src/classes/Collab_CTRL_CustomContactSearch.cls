// Code from: https://blog.jeffdouglas.com/2011/08/12/roll-your-own-salesforce-lookup-popup-window/
//
public with sharing class Collab_CTRL_CustomContactSearch {
  
  public Contact contact {get;set;} // new contact to create
  public List<Contact> results{get;set;} // search results
  public string searchString{get;set;} // search keyword
  
  public Collab_CTRL_CustomContactSearch() {
    contact = new Contact();
    // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksearch');
    runSearch();  
  }
   
  // performs the keyword search
  public PageReference search() {
    runSearch();
    return null;
  }
  
  // prepare the query and issue the search command
  private void runSearch() {
    // TODO prepare query string for complex serarches & prevent injections
    results = performSearch(searchString);               
  } 
  
  // run the search and return the records found. 
  private List<Contact> performSearch(string searchString) {

    String soql = 'select id, name from contact';
    if(searchString != '' && searchString != null)
      soql = soql +  ' where name LIKE \'%' + searchString +'%\'';
    soql = soql + ' limit 25';
    System.debug(soql);
    return database.query(soql); 

  }
  
  // save the new contact record
  public PageReference saveContact() {
    insert contact;
    // reset the contact
    contact = new Contact();
    return null;
  }
  
  // used by the visualforce page to send the link to the right dom element
  public string getFormTag() {
    return System.currentPageReference().getParameters().get('frm');
  }
    
  // used by the visualforce page to send the link to the right dom element for the text box
  public string getTextBox() {
    return System.currentPageReference().getParameters().get('txt');
  }
 
}