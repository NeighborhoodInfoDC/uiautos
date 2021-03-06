/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Delete_metadata_file

 Description: Deletes metadata for a SAS data set.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Delete_metadata_file(  
         ds_lib= ,         /** Data set library reference **/
         ds_name= ,        /** Data set name **/
         meta_lib= ,       /** Metadata library reference **/
         meta_pre= meta,   /** Metadata data set name prefix **/
         update_notify=    /** DEPRECATED PARAMETER **/
  );
  
  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Delete_metadata_file( 
              ds_lib= Health,
              ds_name= Birth_1998_geo00,
              meta_lib= meta
       )
       deletes all metadata for data set Health.Birth_1998_geo00

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   12/20/04  Peter A. Tatian
   09/06/05  Added OPTIONS OBS=MAX to avoid data loss when updating metadata.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %let ds_lib = %upcase( &ds_lib );
  %let ds_name = %upcase( &ds_name );

  %** Save current OBS= setting then set to MAX **;

  %Push_option( obs )
  
  options obs=max;
  %Note_mput( macro=Delete_metadata_file, msg=OPTIONS OBS set to MAX for metadata processing. )

    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  ** Check for existence of library metadata file **;
  
  %if not %Dataset_exists( &meta_lib..&meta_pre._libs, quiet=n ) %then %do;
    %Err_mput( macro=Delete_metadata_file, msg=File &meta_lib..&meta_pre._libs does not exist. )
    %goto exit_err;
  %end;
  
  ** Check that library is registered **;
  
  %Data_to_format( 
    FmtName=$libchk, 
    inDS=&meta_lib..&meta_pre._libs, 
    value=upcase( Library ),
    label="Y",
    otherlabel="N",
    print=N )

  data _null_;
    call symput( 'lib_exists', put( upcase( "&ds_lib" ), $libchk. ) );
  run;
    
  %if &lib_exists = N %then %do;
    %Err_mput( macro=Delete_metadata_file, msg=Library &ds_lib is not registered in the metadata system. )
    %goto exit_err;
  %end;
  

  %***** ***** ***** MACRO BODY ***** ***** *****;

  ** Delete data set from metadata **;
  
  /** Macro _delete_file - Start Definition **/

  %macro _delete_file( metafile= );

    %if %Dataset_exists( &metafile, quiet=n ) %then %do;
  
      data &metafile (compress=char);

        set &metafile;
        
        if library = "&ds_lib" and FileName = "&ds_name"
          then delete;
      
      run;
    
    %end;
  
  %mend _delete_file;

  /** End Macro Definition **/

  %_delete_file( metafile=&meta_lib..&meta_pre._files )
  %_delete_file( metafile=&meta_lib..&meta_pre._vars )
  %_delete_file( metafile=&meta_lib..&meta_pre._fval )
  %_delete_file( metafile=&meta_lib..&meta_pre._history )
  
  %Note_mput( macro=Delete_metadata_file, msg=Data set &ds_lib..&ds_name deleted from metadata. )
  
  %goto exit;
  
  %exit_err:
  
  %Err_mput( macro=Delete_metadata_file, msg=Data set &ds_lib..&ds_name was not deleted from metadata system. )
  %goto exit;
  
  %exit:
  
  %***** ***** ***** CLEAN UP ***** ***** *****;

  %** Restore system options **;
  
  %Pop_option( obs )

  %Note_mput( macro=Delete_metadata_file, msg=Macro exiting. )

%mend Delete_metadata_file;


/************************ UNCOMMENT TO TEST ***************************

** Autocall macros **;

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

proc format library=work;
  value $region
    "Africa" = "~Africa"
    "Asia" = "~Asia"
    "Canada" = "~Canada"
    "Central America/Caribbean" = "~Central America/Caribbean"
    "Eastern Europe" = "~Eastern Europe"
    "Middle East" = "~Middle East"
    "Pacific" = "~Pacific"
    "South America" = "~South America"
    "United States" = "~United States"
    "Western Europe" = "~Western Europe";
    
data Shoes;

  set Sashelp.shoes;
  
  format region $region.;
  
run;

data Class;

  set Sashelp.class;
  
  label
    Age = "Age (years)";

run;

%Update_metadata_library( 
         lib_name=Work,
         lib_desc=Test library,
         meta_lib=work
      )

%Update_metadata_file( 
         ds_lib=Work,
         ds_name=Shoes,
         creator=SAS Institute,
         creator_process=SAS Institute,
         revisions=Test file.,
         meta_lib=work
      )

%Update_metadata_file( 
         ds_lib=Work,
         ds_name=Class,
         creator=SAS Institute,
         creator_process=SAS Institute,
         revisions=Test file #2.,
         meta_lib=work
      )

proc datasets library=work memtype=(data);
quit;

title1 "BEFORE FILE DELETE";
%File_info( data=Meta_files, printobs=50, contents=n, stats= )
%File_info( data=Meta_vars, printobs=50, contents=n, stats= )
%File_info( data=Meta_fval, printobs=50, contents=n, stats= )
%File_info( data=Meta_history, printobs=50, contents=n, stats= )

%Delete_metadata_file( 
         ds_lib= Work,
         ds_name= Shoes,
         meta_lib= work
  )

title1 "AFTER FILE DELETE";
%File_info( data=Meta_files, printobs=50, contents=n, stats= )
%File_info( data=Meta_vars, printobs=50, contents=n, stats= )
%File_info( data=Meta_fval, printobs=50, contents=n, stats= )
%File_info( data=Meta_history, printobs=50, contents=n, stats= )

/**********************************************************************/
