/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: ListChangeDelim

 Description: Change delimiters in a macro variable list:  default is change
 from spaces to commas.  Optionally add prefix to list items.
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro ListChangeDelim(  
  list ,                   /** List to process **/
  old_delim = %str( ),     /** Old list delimiter **/
  new_delim = %str(,),     /** New list delimiter **/
  prefix = ,               /** Prefix to add before list items (optional) **/
  suffix = ,               /** Suffix to add after list items (optional) **/
  quiet=N                  /** Suppress log messages? (Y/N) **/
);

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %ListChangeDelim( %str(a,b,c,d,e,f,g), old_delim=%str(,), new_delim=%str( ) );
       returns the list with delimiters changed from , to blank space
   
     %ListChangeDelim( a b c d e f g, prefix=data. )
       returns the list with data. prefixed to each item

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   06/27/05  Peter A. Tatian
   08/20/06  Added suffix= parameter.
   02/23/11  PAT  Added declaration for local macro vars.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local i item new_list;

    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  %if not %mparam_is_yes( &quiet ) %then %do;
    %note_mput( macro=ListChangeDelim, msg=Processing list=&list )
  %end;

  %let i = 1;
  %let item = %scan( &list, &i, &old_delim );
  %let new_list = ;

  %do %while ( %length( &item ) > 0 );
  
    %let new_list = &new_list&prefix&item&suffix;
    
    %let i = %eval( &i + 1 );
    %let item = %scan( &list, &i, &old_delim );
    
    %if &item ~= %then %let new_list = &new_list&new_delim;

  %end;
  
  %if not %mparam_is_yes( &quiet ) %then %do;
    %note_mput( macro=ListChangeDelim, msg=New list=&new_list )
  %end;

  &new_list


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend ListChangeDelim;


/************************ UNCOMMENT TO TEST ***************************

title "ListChangeDelim:  UI SAS Autocall Macro Library";

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

options nocenter;
options mprint nosymbolgen nomlogic;
options msglevel=i;

%put Result=%ListChangeDelim(  );

%put Result=%ListChangeDelim( a );

%put Result=%ListChangeDelim( a b );

%put Result=%ListChangeDelim( a b c d e f g );

%put Result=%ListChangeDelim( a b c d e f g, prefix=data. );

%put Result=%ListChangeDelim( a b c d e f g, new_delim=%str(, ) );

%put Result=%ListChangeDelim( %str(a,b,c,d,e,f,g), old_delim=%str(,), new_delim=%str( ) );

run;

/**********************************************************************/

