app-text/libetonyek-0.1.10 - error: 'bool_constant' is not a member of 'std'
===============================================================================================================
  CXX      libetonyek_internal_la-IWAMessage.lo
  CXX      libetonyek_internal_la-IWAObjectIndex.lo
  CXX      libetonyek_internal_la-IWAParser.lo
In file included from /usr/include/mdds-2.1/mdds/flat_segment_tree.hpp:39,
                 from IWORKTypes.h:26,
                 from IWAObjectIndex.cpp:16:
/usr/include/mdds-2.1/mdds/global.hpp:161:47: error: 'bool_constant' is not a member of 'std'
  161 | using const_t = typename const_or_not<T, std::bool_constant<Const>>::type;
      |                                               ^~~~~~~~~~~~~
/usr/include/mdds-2.1/mdds/global.hpp:161:47: error: 'bool_constant' is not a member of 'std'
/usr/include/mdds-2.1/mdds/global.hpp:161:61: error: template argument 2 is invalid
  161 | using const_t = typename const_or_not<T, std::bool_constant<Const>>::type;
      |                                                             ^~~~~
/usr/include/mdds-2.1/mdds/global.hpp:161:26: error: expected nested-name-specifier
  161 | using const_t = typename const_or_not<T, std::bool_constant<Const>>::type;
      |                          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------
Failed make build
===============================================================================================================