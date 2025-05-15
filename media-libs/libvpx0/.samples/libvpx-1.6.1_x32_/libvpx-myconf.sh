# vpx_ports/emms_mmx.asm:408: error: symbol `CONFIG_POSTPROC' not defined before use
MYCONF+=(
  --disable-vp9-highbitdepth
  # postproc - x32 no support?
  --disable-postproc
)