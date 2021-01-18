@AbapCatalog.sqlViewName: 'ZICVPROVINCEVH'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Province'
@AbapCatalog.preserveKey: true
@VDM.viewType: #BASIC
@ObjectModel.semanticKey: ['Province', 'Country']
@ObjectModel.representativeKey: ['Province', 'Country']
define view Z_I_CV_PROVINCEVH
  as select from Z_I_CV_PROVINCE
{

  @ObjectModel.text.element: [ 'ISO3' ]
  key Province as Province,
  @Semantics.text: true
  @Semantics.name.fullName: true
  key Country   as Country,
  @Semantics.text: true
  @Semantics.name.fullName: true
  ISO3              as ISO3,
  @Semantics.text: true
  @Semantics.name.fullName: true
  ISO2              as ISO2,
  countryID         as countryID
}
