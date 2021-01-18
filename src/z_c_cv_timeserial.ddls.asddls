@EndUserText.label: 'TimeSerial Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions:true
@VDM.viewType: #CONSUMPTION
define view entity Z_C_CV_TIMESERIAL
  as projection on Z_I_CV_TIMESERIAL
{
      @Semantics.text: true
      @EndUserText.label: 'Country'
      @Consumption.valueHelpDefinition: [{entity:{name:'Z_I_CV_COUNTRYVH' , element: 'Country'}}]
      @Consumption.semanticObject: 'Countries'
  key Country ,
  
      @Search.defaultSearchElement : true
      @Search.fuzzinessThreshold : 0.8
      @Semantics.text: true
      @EndUserText.label: 'Province'
      @Consumption.valueHelpDefinition: [{entity:{name:'Z_I_CV_PROVINCEVH' , element: 'Province'}}]  
  key Province ,
       @EndUserText.label: 'Date'   
  key Timeline ,
      Cases ,
      DeathsCriticality ,
      Deaths ,
      RecoveredCriticality ,
      Recovered,

      @EndUserText.label: 'Created by'
      @Consumption.filter.hidden: true
      CreatedBy,
      
      @EndUserText.label: 'Created At'
      @Consumption.filter.hidden: true
      CreatedAt,
      
      @EndUserText.label: 'Last changed by'
      @Consumption.filter.hidden: true
      LastChangedBy,
      
      @EndUserText.label: 'Last changed At'
      @Consumption.filter.hidden: true
      LastChangedAt,
      
      @EndUserText.label: 'Local Last changed At'
      @Consumption.filter.hidden: true      
      LocalLastChangedAt,
      
      
      /* Associations */
      _CountryRoot: redirected to parent Z_C_CV_COUNTRYROOT
}
