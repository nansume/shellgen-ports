Date: 2023.10.05

BUG: `sdl` package: not found libs and headers `libusbhid`

# -------------------------------------------------------------

FIX:

```
  $ ln -s libhid.so.0.0.0 /libx32/libusbhid.so
  $ ln -s hid.h /usr/include/libusbhid.h
  $ ln -s hid.h /usr/include/usbhid.h
  $ ln -s /usr/include/libusb-1.0/libusb.h /usr/include/libusb.h
```

# --------------------------------------------------------------

 It bug close.