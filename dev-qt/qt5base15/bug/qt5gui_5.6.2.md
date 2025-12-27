../../include/QtGui/../../src/gui/painting/qtransform.h:382:35: warning: implicitly-declared 'QTransform::QTransform(const QTransform&)' is deprecated -Wdeprecated-copy
  382 | { QTransform t(a); t -= n; return t; }
../../include/QtGui/../../src/gui/painting/qtransform.h:121:17: note: because 'QTransform' has user-provided 'QTransform& QTransform::operator=(const QTransform&)'
  121 |     QTransform &operator=(const QTransform &);
/usr/lib/gcc/i686-pc-linux-gnu/9.2.0/../../../../i686-pc-linux-gnu/bin/ld.gold: error: cannot find -lqtharfbuzzng
.obj/qfontengine.o:qfontengine.cpp:function QFontEngine::supportsScript(QChar::Script) const: error: undefined reference to 'hb_ot_tags_from_script'
.obj/qfontengine.o:qfontengine.cpp:function QFontEngine::supportsScript(QChar::Script) const: error: undefined reference to 'hb_ot_layout_table_find_script'
.obj/qfontengine.o:qfontengine.cpp:function QFontEngine::supportsScript(QChar::Script) const: error: undefined reference to 'hb_ot_layout_table_find_script'
.obj/qfontengine.o:qfontengine.cpp:function QFontEngine::supportsScript(QChar::Script) const: error: undefined reference to 'hb_ot_layout_table_find_script'
.obj/qtextengine.o:qtextengine.cpp:function QTextEngine::shapeTextWithHarfbuzzNG(QScriptItem const&, unsigned short const*, int, QFontEngine*, QVector<unsigned
int> const&, bool, bool) const: error: undefined reference to 'hb_buffer_create'