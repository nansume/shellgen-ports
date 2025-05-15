MYCONF="${MYCONF}
  $(useis 'unicode' && $(use_enable 'unicode') )
  $(useis 'test' && $(use_enable 'test' tests) )
"
