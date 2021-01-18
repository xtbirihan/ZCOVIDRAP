@AbapCatalog.sqlViewName: 'ZICVCOUNTRYVH'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Country'
@Analytics.dataCategory: #DIMENSION
@VDM.viewType: #BASIC
@ObjectModel.semanticKey: ['Country']
@ObjectModel.representativeKey: 'Country'
define view Z_I_CV_COUNTRYVH
  as select from zcv_t_02
{

      @ObjectModel.text.element: [ 'ISO3' ]
  key country as Country,
      @Semantics.text: true
      @Semantics.name.fullName: true
      iso_3   as Iso3,
      @Semantics.text: true
      @Semantics.name.fullName: true      
      iso_2   as Iso2,
      id      as CountryID

}
