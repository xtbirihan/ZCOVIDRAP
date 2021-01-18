@AbapCatalog.sqlViewName: 'ZICOUNTRYROOT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Country Root'
@VDM.viewType: #COMPOSITE
define root view Z_I_CV_COUNTRYROOT
  as select from zcv_t_01
  composition [0..*] of Z_I_CV_COUNTRYPROVINCE as _CountryProvince
  composition [0..*] of Z_I_CV_TIMESERIAL      as _TimeSerial
  association [0..1] to zcv_t_02 as _information on $projection.Country = _information.country
{
  key country                   as Country,
      updated                   as Updated,
      
      @DefaultAggregation: #NONE     
      cases                     as Cases,

      case when today_cases > 0
           then 2
           else 0 
       end as TodayCasesCriticality,
      
      @DefaultAggregation: #NONE
      today_cases               as TodayCases,

      case when deaths > 0
           then 1
           else 0 
       end as DeathsCriticality,

      @DefaultAggregation: #NONE
      deaths                    as Deaths,

      case when today_deaths > 0
           then 1
           else 0 
       end as TodayDeathsCriticality,

      @DefaultAggregation: #NONE     
      today_deaths              as TodayDeaths,

      case when recovered > 0
           then 3
           else 0 
       end as RecoveredCriticality,

      @DefaultAggregation: #NONE
      recovered                 as Recovered,
   
      case when today_recovered > 0
           then 3
           else 0 
       end as TodayRecoveredCriticality,   
     
      @DefaultAggregation: #NONE
      today_recovered           as TodayRecovered,
    
      @DefaultAggregation: #NONE
      active                    as Active,

      @DefaultAggregation: #NONE      
      critical                  as Critical,
       
      @DefaultAggregation: #NONE    
      cases_per_one_million     as CasesPerOneMillion,
      
       
      @DefaultAggregation: #NONE    
      deaths_per_one_million    as DeathsPerOneMillion,

       
      @DefaultAggregation: #NONE     
      tests                     as Tests,

      @DefaultAggregation: #NONE    
      tests_per_one_million     as TestsPerOneMillion,

      @DefaultAggregation: #NONE     
      population                as Population,
      continent                 as Continent,

      @DefaultAggregation: #NONE      
      one_case_per_people       as OneCasePerPeople,
       
      @DefaultAggregation: #NONE     
      one_death_per_people      as OneDeathPerPeople,
       
      @DefaultAggregation: #NONE     
      one_test_per_people       as OneTestPerPeople,

      @DefaultAggregation: #NONE     
      active_per_one_million    as ActivePerOneMillion,
       
      @DefaultAggregation: #NONE      
      recovered_per_one_million as RecoveredPerOneMillion,
       
      @DefaultAggregation: #NONE    
      critical_per_one_million  as CriticalPerOneMillion,
     
      @Semantics.user.createdBy: true
      created_by                as CreatedBy,
      
      @Semantics.systemDateTime.createdAt: true
      created_at                as CreatedAt,
      
      @Semantics.user.lastChangedBy: true
      last_changed_by           as LastChangedBy,
      
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at           as LastChangedAt,
      
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_changed_at     as LocalLastChangedAt,
     
      
      @Semantics.imageUrl: true
      _information.flag         as Flag, 
      _information.id                    as ID,
      _information.iso_2                 as Iso2,
      _information.iso_3                 as Iso3,
      @Semantics.geoLocation.latitude      
      _information.latitude              as Latitude,
      @Semantics.geoLocation.longitude
      _information.longitude             as Longitude,
      cast( '1000000' as abap.dec( 13, 0 )) as million, 
      
      case when tests_per_one_million >= 750000  then 3
           when tests_per_one_million  >= 500000  
            and tests_per_one_million < 750000   then 2
           when tests_per_one_million  >= 1      
            and tests_per_one_million < 500000  then 1 
        else 0 end as TestsCriticality,
      
       // Associations
      _CountryProvince,
      _TimeSerial,
      _information

}
