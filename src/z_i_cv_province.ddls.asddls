@AbapCatalog.sqlViewName: 'ZICVPROVINCE'
@VDM.viewType: #BASIC
@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Province'
@ObjectModel.semanticKey: ['Province', 'Country']
@AbapCatalog.preserveKey: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.representativeKey: ['Province', 'Country']
define view Z_I_CV_PROVINCE
  as select from zcv_t_03 as _Province
      association[0..1] to zcv_t_02 as _country on _Province.country = _country.country
{

  @ObjectModel.text.element: [ 'ISO3' ]
  key  _Province.province as Province,
  @Semantics.text: true
  @EndUserText.label: 'Country'
  key _country.country   as Country,
    @Semantics.text: true
  @EndUserText.label: 'Iso Code'
  _country.iso_3              as ISO3,
  @Semantics.text: true
  @EndUserText.label: 'Iso Code'  
  _country.iso_2              as ISO2,
  _country.id                 as countryID

}
where _Province.province <> ' ' 
