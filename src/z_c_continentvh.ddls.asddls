@AbapCatalog.sqlViewName: 'ZCCONTINENTVH'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Continent'
@Search.searchable: true
@ObjectModel.semanticKey:  [ 'continent' ]
@ObjectModel.representativeKey: ['continent']
@VDM.viewType: #CONSUMPTION

@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.dataCategory: #VALUE_HELP
define view Z_C_ContinentVH
  as select from Z_I_CV_CONTINENT
{
      @ObjectModel.text.element: ['Continent']
    
  key Continent, 
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.7 }
      ContinentText

}
where Continent <> ' '
