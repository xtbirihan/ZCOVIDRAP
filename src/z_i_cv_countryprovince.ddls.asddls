@AbapCatalog.sqlViewName: 'ZCVCTRYPROVINCE'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Country Province Composition Child'
@VDM.viewType: #COMPOSITE
define view Z_I_CV_COUNTRYPROVINCE
  as select from zcv_t_03
  association to parent Z_I_CV_COUNTRYROOT as _CountryRoot  on $projection.Country = _CountryRoot.Country
{
  key country               as Country,
  key province              as Province,
      county                as County,
             
      @DefaultAggregation: #NONE        
      confirmed             as Confirmed,

      case when deaths > 0
           then 1
           else 0 
       end as DeathsCriticality,
      
      @DefaultAggregation: #NONE   
      deaths                as Deaths,

      case when recovered > 0
           then 3
           else 0 
       end as RecoveredCriticality,
       
      @DefaultAggregation: #NONE        
      recovered             as Recovered,
      
      updateddate           as Updateddate,
      updatedtime           as Updatedtime,

      @Semantics.geoLocation.latitude
      latitude              as Latitude,
      @Semantics.geoLocation.longitude
      longitude             as Longitude,
      
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,

      @Semantics.systemDateTime.createdAt: true      
      created_at            as CreatedAt,
      
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      
       /* Associations */
      _CountryRoot
}
