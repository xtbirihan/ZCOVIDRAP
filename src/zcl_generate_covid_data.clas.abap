CLASS zcl_generate_covid_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

    METHODS:
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_http_client
        RAISING   cx_static_check,

      read_posts
        IMPORTING url             TYPE string
        RETURNING VALUE(response) TYPE string
        RAISING   cx_static_check.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      base_url       TYPE string VALUE 'https://disease.sh/v3/covid-19/countries',
      content_type   TYPE string VALUE 'Content-type',
      json_content   TYPE string VALUE 'application/json; charset=UTF-8',
      province_url   TYPE string VALUE 'https://disease.sh/v3/covid-19/jhucsse',
      historical_url TYPE string VALUE 'https://disease.sh/v3/covid-19/historical?lastdays=30',
      allsum_url     TYPE string VALUE 'https://disease.sh/v3/covid-19/all',
      timeserial_url TYPE string VALUE 'https://disease.sh/v3/covid-19/historical/all?lastdays=30'.


    METHODS:
      clean,

      extract_countrydata
        IMPORTING response TYPE string
        RAISING   cx_static_check,

      extract_provincedata
        IMPORTING response TYPE string
        RAISING   cx_static_check,

      extract_historicaldata
        IMPORTING response TYPE string
        RAISING   cx_static_check,

      extract_allsum
        IMPORTING response TYPE string
        RAISING   cx_static_check,

      extract_timeserialdata
        IMPORTING response TYPE string
        RAISING   cx_static_check,

      check_and_save_countrydata
        IMPORTING it_countrydata TYPE zcv_tt_01
        RAISING   cx_static_check,

      check_and_save_provincedata
        IMPORTING it_provincedata TYPE zcv_tt_02
        RAISING   cx_static_check,

      check_and_save_historicaldata
        IMPORTING ir_data TYPE REF TO data
        RAISING   cx_static_check,

      check_and_save_timeserialdata
        IMPORTING ir_data TYPE REF TO data
        RAISING   cx_static_check,

      check_and_save_allsum
        IMPORTING is_allsum TYPE zcv_s_06
        RAISING   cx_static_check,

      normalize_historicaldata
        IMPORTING is_timeline TYPE any
                  iv_country  TYPE landx50
                  iv_province TYPE char50
        CHANGING  it_data     TYPE zcv_tt_03
        RAISING   cx_static_check,

      upper_case_first_letter
        CHANGING VALUE(cv_word) TYPE char50
        RAISING  cx_static_check.
ENDCLASS.

CLASS zcl_generate_covid_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    TRY.
        me->clean( ).

        DATA(country_response) = read_posts( url = me->base_url  ).
        me->extract_countrydata( response = country_response ).

        DATA(province_response) = read_posts( url = me->province_url  ).
        me->extract_provincedata( response =  province_response ).

        DATA(historical_response) = read_posts( url = me->historical_url  ).
        me->extract_historicaldata(  response = historical_response ).

        DATA(allsum_response) = read_posts( url = me->allsum_url ).
        me->extract_allsum( response =  allsum_response ).

        DATA(timeserial_response) = read_posts( url = me->timeserial_url ).
        me->extract_timeserialdata( response =  timeserial_response ).


      CATCH cx_root INTO DATA(exc).
        out->write( exc->get_text(  ) ).
    ENDTRY.


  ENDMETHOD.
  METHOD create_client.
    DATA: lv_sysubrc     TYPE sysubrc.
    cl_http_client=>create_by_url(
      EXPORTING
        url                    = url
      IMPORTING
        client                 = result
      EXCEPTIONS
        argument_not_found     = 1
        plugin_not_active      = 2
        internal_error         = 3
        pse_not_found          = 4
        pse_not_distrib        = 5
        pse_errors             = 6
        OTHERS                 = 7
    ).
    ASSERT sy-subrc = 0.
    result->propertytype_accept_cookie = if_http_client=>co_enabled.
    result->request->set_method( if_http_request=>co_request_method_get ).

    result->request->set_header_field( name = me->content_type value = if_rest_media_type=>gc_appl_json ).
    result->request->set_header_field( name = 'Accept' value = if_rest_media_type=>gc_appl_json ).
    result->send( EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3 ).
    ASSERT sy-subrc = 0.

    result->receive(
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state         = 2
          http_processing_failed     = 3 ).
    IF sy-subrc <> 0.
      result->get_last_error(
         IMPORTING
           code    = lv_sysubrc
           message = DATA(ev_message) ).
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD extract_countrydata.
    DATA: result TYPE zcv_tt_01.

    /ui2/cl_json=>deserialize( EXPORTING json = response
                                         pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                         assoc_arrays = abap_true
                                CHANGING data = result ).

    me->check_and_save_countrydata( result ).
  ENDMETHOD.

  METHOD extract_historicaldata.
    DATA:  result TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = response
                                         pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                         assoc_arrays = abap_true
                                CHANGING data = result ).

    me->check_and_save_historicaldata( result ).
  ENDMETHOD.

  METHOD extract_provincedata.
    DATA: result TYPE zcv_tt_02.
    /ui2/cl_json=>deserialize( EXPORTING json = response
                                         pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                         assoc_arrays = abap_true
                                CHANGING data = result ).

    me->check_and_save_provincedata( it_provincedata = result ).

  ENDMETHOD.

  METHOD read_posts.
    DATA(client) = create_client( url ).
    response = client->response->get_cdata( ).
    client->close(  ).
  ENDMETHOD.

  METHOD check_and_save_countrydata.
    DATA: lt_country      TYPE STANDARD TABLE OF zcv_t_01,
          ls_country      TYPE zcv_t_01,
          lt_country_info TYPE STANDARD TABLE OF zcv_t_02,
          ls_country_info TYPE zcv_t_02,
          lv_ts           TYPE timestampl.

    GET TIME STAMP FIELD lv_ts.

    LOOP AT it_countrydata ASSIGNING FIELD-SYMBOL(<fs_data>).
      ls_country      = CORRESPONDING #( <fs_data> ).
      ls_country_info = CORRESPONDING #( <fs_data>-country_info ).

      ls_country-mandt = sy-mandt.
      ls_country-created_by  = sy-uname.
      ls_country-created_at       = lv_ts.
      ls_country-last_changed_by  = sy-uname.
      ls_country-last_changed_at  = lv_ts.
      ls_country-local_last_changed_at  = lv_ts.

      ls_country_info = CORRESPONDING #( BASE ( ls_country_info ) ls_country ).
      ls_country_info-id = <fs_data>-country_info-_id.
      ls_country_info-latitude = <fs_data>-country_info-lat.
      ls_country_info-longitude = <fs_data>-country_info-long.

      APPEND ls_country TO lt_country.
      APPEND ls_country_info TO lt_country_info.
      CLEAR: ls_country, ls_country_info.
    ENDLOOP.
    MODIFY zcv_t_01 FROM TABLE lt_country.
    MODIFY zcv_t_02 FROM TABLE lt_country_info.

  ENDMETHOD.

  METHOD check_and_save_provincedata.
    DATA: lt_province TYPE STANDARD TABLE OF zcv_t_03,
          lv_ts       TYPE timestampl,
          lv_province TYPE char50.
    GET TIME STAMP FIELD lv_ts.

    LOOP AT it_provincedata ASSIGNING FIELD-SYMBOL(<fs_data>).
      CLEAR: lv_province.
      lv_province = <fs_data>-province.
      me->upper_case_first_letter(  CHANGING cv_word = lv_province  ).
      APPEND VALUE zcv_t_03( mandt       = sy-mandt
                             country     = COND #( WHEN <fs_data>-country = 'USA' THEN 'US'
                                                   WHEN <fs_data>-country = 'United Arab Emirates' THEN 'UAE'
                                                   WHEN <fs_data>-country = 'United Kingdom' then 'UK'
                                                   else <fs_data>-country )
                             province    = <fs_data>-province
                             county      = <fs_data>-county
                             confirmed   = <fs_data>-stats-confirmed
                             deaths      = <fs_data>-stats-deaths
                             recovered   = <fs_data>-stats-recovered
                             longitude   = <fs_data>-coordinates-longitude
                             latitude    = <fs_data>-coordinates-latitude
                             updateddate = <fs_data>-updated_at+0(4) && <fs_data>-updated_at+5(2) && <fs_data>-updated_at+8(2)
                             updatedtime = <fs_data>-updated_at+11(2) && <fs_data>-updated_at+14(2) && <fs_data>-updated_at+17(2)
                             created_by  = sy-uname
                             created_at  = lv_ts
                             last_changed_by = sy-uname
                             last_changed_at = lv_ts
                             local_last_changed_at = lv_ts ) TO lt_province.
    ENDLOOP.

    MODIFY zcv_t_03 FROM TABLE lt_province.
  ENDMETHOD.

  METHOD check_and_save_historicaldata.
    DATA: lt_historical TYPE STANDARD TABLE OF zcv_t_04,
          ls_historical TYPE zcv_t_04,
          lv_fname(30).

    FIELD-SYMBOLS: <fs_historical> TYPE zcv_t_04.
    FIELD-SYMBOLS: <fs_data>     TYPE STANDARD TABLE.

    ASSIGN ir_data->* TO  <fs_data>.
    LOOP AT <fs_data> ASSIGNING FIELD-SYMBOL(<fs_line>).

      lv_fname = '<FS_LINE>->COUNTRY->*'.
      ASSIGN (lv_fname) TO FIELD-SYMBOL(<fs_field>).
      IF <fs_field> IS ASSIGNED.
        ls_historical-country = <fs_field>.
        UNASSIGN <fs_field>.
      ENDIF.

      lv_fname = '<FS_LINE>->PROVINCE->*'.
      ASSIGN (lv_fname) TO <fs_field>.
      IF <fs_field> IS ASSIGNED.
        ls_historical-province = <fs_field>.
        me->upper_case_first_letter(  CHANGING cv_word = ls_historical-province  ).
        UNASSIGN <fs_field>.
      ENDIF.

      lv_fname = '<FS_LINE>->TIMELINE->*'.
      ASSIGN (lv_fname) TO FIELD-SYMBOL(<fs_timeline>).
      IF <fs_timeline> IS ASSIGNED.
        me->normalize_historicaldata(
          EXPORTING
            is_timeline = <fs_timeline>
            iv_country  = ls_historical-country
            iv_province = ls_historical-province
          CHANGING
            it_data     = lt_historical
        ).
        UNASSIGN <fs_timeline>.
      ENDIF.
      clear: ls_historical.

  ENDLOOP.

  MODIFY zcv_t_04 FROM TABLE lt_historical.
ENDMETHOD.

METHOD clean.
  DELETE FROM zcv_t_01.
  DELETE FROM zcv_t_02.
  DELETE FROM zcv_t_03.
  DELETE FROM zcv_t_04.
  DELETE FROM zcv_t_05.
  DELETE FROM zcv_t_06.
ENDMETHOD.

METHOD normalize_historicaldata.
  DATA: lv_fname(30),
        lv_date      TYPE sy-datum,
        lv_day(2),
        lv_month(2),
        lv_year(2),
        lv_ts        TYPE timestampl,
        ls_history   TYPE zcv_t_04.

  GET TIME STAMP FIELD lv_ts.

  lv_fname = 'IS_TIMELINE-CASES->*'.
  ASSIGN (lv_fname) TO FIELD-SYMBOL(<fs_cases>).

  lv_fname = 'IS_TIMELINE-DEATHS->*'.
  ASSIGN (lv_fname) TO FIELD-SYMBOL(<fs_deaths>).

  lv_fname = 'IS_TIMELINE-RECOVERED->*'.
  ASSIGN (lv_fname) TO FIELD-SYMBOL(<fs_recovered>).

  lv_date = sy-datum - 1.

  DO 30 TIMES.
    lv_day   = |{ lv_date+6(2) ALPHA = OUT }|.
    lv_month = |{ lv_date+4(2) ALPHA = OUT }|.
    lv_year  = lv_date+2(2).
    DATA(lv_name) = |<FS_CASES>-| && |{ lv_month }| && |_| && |{ lv_day }| && |_| &&  |{ lv_year }| && |->*|.

    ASSIGN (lv_name) TO FIELD-SYMBOL(<fs_num>).
    IF <fs_num> IS ASSIGNED.
      ls_history-cases = <fs_num>.
      UNASSIGN: <fs_num>.
    ENDIF.
    CLEAR: lv_name.

    lv_name = |<FS_DEATHS>-| && |{ lv_month }| && |_| && |{ lv_day }| && |_| &&  |{ lv_year }| && |->*|.
    ASSIGN (lv_name) TO <fs_num>.
    IF <fs_num> IS ASSIGNED.
      ls_history-deaths = <fs_num>.
      UNASSIGN: <fs_num>.
    ENDIF.
    CLEAR: lv_name.

    lv_name = |<FS_RECOVERED>-| && |{ lv_month }| && |_| && |{ lv_day }| && |_| &&  |{ lv_year }| && |->*|.
    ASSIGN (lv_name) TO <fs_num>.
    IF <fs_num> IS ASSIGNED.
      ls_history-recovered = <fs_num>.
      UNASSIGN: <fs_num>.
    ENDIF.

    APPEND VALUE zcv_t_04( mandt           = sy-mandt
                           country         = iv_country
                           province        = iv_province
                           timeline        = lv_date
                           cases           = ls_history-cases
                           deaths          = ls_history-deaths
                           recovered       = ls_history-recovered
                           created_by      = sy-uname
                           created_at      = lv_ts
                           last_changed_by = sy-uname
                           last_changed_at = lv_ts
                           local_last_changed_at = lv_ts ) TO it_data.
    lv_date -= 1.
    CLEAR: lv_day, lv_month, lv_year, lv_name, ls_history.
  ENDDO.


  IF <fs_cases> IS ASSIGNED.
    UNASSIGN: <fs_cases>.
  ENDIF.

  IF <fs_deaths> IS ASSIGNED.
    UNASSIGN: <fs_deaths>.
  ENDIF.

  IF <fs_recovered> IS ASSIGNED.
    UNASSIGN: <fs_recovered>.
  ENDIF.

ENDMETHOD.

METHOD extract_allsum.
  DATA: result TYPE zcv_s_06.

  /ui2/cl_json=>deserialize( EXPORTING json = response
                                       pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                              CHANGING data = result ).

  me->check_and_save_allsum( result ).
ENDMETHOD.

METHOD check_and_save_allsum.
  DATA: lt_allsum TYPE STANDARD TABLE OF zcv_t_05,
        lv_ts     TYPE timestampl.

  GET TIME STAMP FIELD lv_ts.

    APPEND VALUE zcv_t_05(  mandt                     = sy-mandt
                            updated                   = is_allsum-updated
                            cases                     = is_allsum-cases
                            today_cases               = is_allsum-today_cases
                            deaths                    = is_allsum-deaths
                            today_deaths              = is_allsum-today_deaths
                            recovered                 = is_allsum-recovered
                            today_recovered           = is_allsum-today_recovered
                            active                    = is_allsum-active
                            critical                  = is_allsum-critical
                            cases_per_one_million     = is_allsum-cases_per_one_million
                            deaths_per_one_million    = is_allsum-deaths_per_one_million
                            tests                     = is_allsum-tests
                            tests_per_one_million     = is_allsum-tests_per_one_million
                            population                = is_allsum-population
                            one_case_per_people       = is_allsum-one_case_per_people
                            one_death_per_people      = is_allsum-one_death_per_people
                            one_test_per_people       = is_allsum-one_test_per_people
                            active_per_one_million    = is_allsum-active_per_one_million
                            recovered_per_one_million = is_allsum-recovered_per_one_million
                            critical_per_one_million  = is_allsum-critical_per_one_million
                            affected_countries        = is_allsum-affected_countries
                            created_by                = sy-uname
                            created_at                = lv_ts
                            last_changed_by           = sy-uname
                            last_changed_at           = lv_ts
                            local_last_changed_at     = lv_ts ) TO lt_allsum.

  MODIFY zcv_t_05 FROM TABLE lt_allsum.
ENDMETHOD.

METHOD extract_timeserialdata.
  DATA:  result TYPE REF TO data.
  /ui2/cl_json=>deserialize( EXPORTING json = response
                                       pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                       assoc_arrays = abap_true
                              CHANGING data = result ).

  me->check_and_save_timeserialdata( result ).
ENDMETHOD.

METHOD check_and_save_timeserialdata.

  DATA: lv_fname(30),
        lv_date      TYPE sy-datum,
        lv_day(2),
        lv_month(2),
        lv_year(2),
        lv_ts        TYPE timestampl,
        ls_history   TYPE zcv_t_06,
        lt_data      TYPE TABLE OF zcv_t_06.

  GET TIME STAMP FIELD lv_ts.

  ASSIGN ir_data->* TO  FIELD-SYMBOL(<fs_data>).
  IF <fs_data> IS ASSIGNED.

    lv_fname = '<FS_DATA>-CASES->*'.
    ASSIGN (lv_fname) TO FIELD-SYMBOL(<fs_cases>).

    lv_fname = '<FS_DATA>-DEATHS->*'.
    ASSIGN (lv_fname) TO FIELD-SYMBOL(<fs_deaths>).

    lv_fname = '<FS_DATA>-RECOVERED->*'.
    ASSIGN (lv_fname) TO FIELD-SYMBOL(<fs_recovered>).

    lv_date = sy-datum - 1.

    DO 30 TIMES.
      lv_day   = |{ lv_date+6(2) ALPHA = OUT }|.
      lv_month = |{ lv_date+4(2) ALPHA = OUT }|.
      lv_year  = lv_date+2(2).
      DATA(lv_name) = |<FS_CASES>-| && |{ lv_month }| && |_| && |{ lv_day }| && |_| &&  |{ lv_year }| && |->*|.

      ASSIGN (lv_name) TO FIELD-SYMBOL(<fs_num>).
      IF <fs_num> IS ASSIGNED.
        ls_history-cases = <fs_num>.
        UNASSIGN: <fs_num>.
      ENDIF.
      CLEAR: lv_name.

      lv_name = |<FS_DEATHS>-| && |{ lv_month }| && |_| && |{ lv_day }| && |_| &&  |{ lv_year }| && |->*|.
      ASSIGN (lv_name) TO <fs_num>.
      IF <fs_num> IS ASSIGNED.
        ls_history-deaths = <fs_num>.
        UNASSIGN: <fs_num>.
      ENDIF.
      CLEAR: lv_name.

      lv_name = |<FS_RECOVERED>-| && |{ lv_month }| && |_| && |{ lv_day }| && |_| &&  |{ lv_year }| && |->*|.
      ASSIGN (lv_name) TO <fs_num>.
      IF <fs_num> IS ASSIGNED.
        ls_history-recovered = <fs_num>.
        UNASSIGN: <fs_num>.
      ENDIF.

      APPEND VALUE zcv_t_06( mandt           = sy-mandt
                             timeline        = lv_date
                             cases           = ls_history-cases
                             deaths          = ls_history-deaths
                             recovered       = ls_history-recovered
                             created_by      = sy-uname
                             created_at      = lv_ts
                             last_changed_by = sy-uname
                             last_changed_at = lv_ts
                             local_last_changed_at = lv_ts ) TO lt_data.
      lv_date -= 1.
      CLEAR: lv_day, lv_month, lv_year, lv_name, ls_history.
    ENDDO.

    UNASSIGN: <fs_data>.
  ENDIF.

  MODIFY zcv_t_06 FROM TABLE lt_data.
ENDMETHOD.

METHOD upper_case_first_letter.
  DATA: lt_matches TYPE match_result_tab,
        ls_match   TYPE match_result.

  FIND ALL OCCURRENCES OF REGEX '\<[[:lower:]]' IN cv_word RESULTS lt_matches.
  LOOP AT lt_matches INTO ls_match.
    TRANSLATE cv_word+ls_match-offset(1) TO UPPER CASE.
  ENDLOOP.

ENDMETHOD.

ENDCLASS.
