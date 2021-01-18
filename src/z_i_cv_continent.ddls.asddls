@AbapCatalog.sqlViewName: 'ZICVCONTINENT'
@VDM.viewType: #BASIC
@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Conitents'
@ObjectModel.representativeKey: 'Continent'
@ObjectModel.semanticKey: ['Continent']
@Analytics.dataCategory: #DIMENSION
@ObjectModel.resultSet.sizeCategory: #XS
define view Z_I_CV_CONTINENT
  as select from zcv_t_01
{
      @ObjectModel.text.element: ['ContinentText']
      @EndUserText.label: 'Continent'
  key continent as Continent,

      @Semantics.text: false
      @EndUserText.label: 'Continent Text'
      continent as ContinentText
}
group by
  continent
