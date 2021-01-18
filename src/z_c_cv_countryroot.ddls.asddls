@EndUserText.label: 'Country Root Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions:true
@VDM.viewType: #CONSUMPTION

define root view entity Z_C_CV_COUNTRYROOT
  as projection on Z_I_CV_COUNTRYROOT
{

      @Search.defaultSearchElement : true
      @Search.fuzzinessThreshold : 0.8
      @Semantics.text: true
      @EndUserText.label: 'Country'
      @Consumption.valueHelpDefinition: [{entity:{name:'Z_I_CV_COUNTRYVH' , element: 'Country'}}]
      @Consumption.semanticObject: 'Countries'
  key Country,
      
      @EndUserText.label: 'Total Cases'
      Cases,
      
      TodayCasesCriticality,
      
      @EndUserText.label: 'Today Cases'   
      TodayCases,
      
      DeathsCriticality,
      Deaths,
      TodayDeathsCriticality,
      
      @EndUserText.label: 'Today Deaths'
      TodayDeaths,
      RecoveredCriticality,
      Recovered,
      TodayRecoveredCriticality,
       @EndUserText.label: 'Today Recovered'
      TodayRecovered,
      Active,
      Critical,
      @EndUserText.label: 'Cases Per One Million'
      CasesPerOneMillion,
      @EndUserText.label: 'Deaths Per One Million'
      DeathsPerOneMillion,
      Tests,
      @EndUserText.label: 'Tests Per One Million'
      TestsPerOneMillion,
      Population,
      
      @Consumption.valueHelpDefinition: [{entity:{name:'Z_C_ContinentVH' , element: 'Continent'}}]
      Continent,
      
      @EndUserText.label: 'Case 1M pop'
      OneCasePerPeople,
      
      @EndUserText.label: 'Death 1M pop'
      OneDeathPerPeople,
      
      @EndUserText.label: 'Test Per People'
      OneTestPerPeople,
      
      @EndUserText.label: 'Active 1M pop'
      ActivePerOneMillion,
      
      @EndUserText.label: 'Recovered 1M pop'
      RecoveredPerOneMillion,
      
      @EndUserText.label: 'Critical 1M pop'
      CriticalPerOneMillion,
      
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
      
    
      @EndUserText.label: 'Flag'
      @Consumption.filter.hidden: true
      @Semantics.imageUrl: true
      Flag,
      
      @EndUserText.label: 'ID'
      ID,
      
      @EndUserText.label: 'Iso Code'
      Iso2,
      
      @EndUserText.label: 'Iso Code'
      Iso3,
      
      @EndUserText.label: 'Latitude'
      Latitude,
      
      @EndUserText.label: 'Longitude'
      Longitude,
       @EndUserText.label: 'Million'
      million,
      TestsCriticality,
      
      
      /* Associations */
      _CountryProvince: redirected to composition child Z_C_CV_COUNTRYPROVINCE,
      _information,
      _TimeSerial : redirected to composition child Z_C_CV_TIMESERIAL
}
