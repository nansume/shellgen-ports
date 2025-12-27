
                 ***************************************************************
                 **  pound-4.16 (musl) - SSL_CTX_use_PrivateKey_file - Error  **
                 ***************************************************************

  BUG (runtime):
  ------------------------------------------------------------------------------------------
  SSL_CTX_use_PrivateKey_file XXXXXXX: error:XXXXXXX:PEM routines:PEM_read_*:no start line
  ------------------------------------------------------------------------------------------

  FIX:
  ------------------------------------------------------------------------------------------
   % cat /etc/ssl/private/<myhost>.key /etc/ssl/<myhost>.pem > /etc/ssl/<myhost>-pound.pem
  ------------------------------------------------------------------------------------------

 https://www.productionmonkeys.net/guides/web-server/pound/pound-ssl-proxy