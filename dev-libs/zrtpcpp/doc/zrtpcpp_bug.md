==================================================================================================================
dev-libs/zrtpcpp-4.7.0 - error: 'uint' was not declared
==================================================================================================================
[ 10%] Building CXX object clients/ccrtp/CMakeFiles/zrtpcpp.dir/__/__/zrtp/ZrtpPacketDHPart.cpp.o
[ 11%] Building CXX object clients/ccrtp/CMakeFiles/zrtpcpp.dir/__/__/zrtp/ZrtpPacketGoClear.cpp.o
/build/ZRTPCPP-4.7.0/zrtp/ZRtp.cpp: In member function 'ZrtpPacketConfirm* ZRtp::prepareConfirm2(ZrtpPacketConfirm*, uint32_t*)':
/build/ZRTPCPP-4.7.0/zrtp/ZRtp.cpp:950:48: error: 'uint' was not declared in this scope; did you mean 'int'?
  950 |     uint32_t hmlen = (confirm1->getLength() - (uint)9) * ZRTP_WORD_SIZE;
      |                                                ^~~~
      |                                                int
/build/ZRTPCPP-4.7.0/zrtp/ZRtp.cpp:950:53: error: expected ')' before numeric constant
  950 |     uint32_t hmlen = (confirm1->getLength() - (uint)9) * ZRTP_WORD_SIZE;
      |                      ~                              ^
      |                                                     )
/build/ZRTPCPP-4.7.0/zrtp/ZRtp.cpp:1036:47: error: expected ')' before numeric constant
 1036 |     hmlen = (zrtpConfirm2.getLength() - (uint)9) * ZRTP_WORD_SIZE;
Failed make build
==================================================================================================================