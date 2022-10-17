#!/bin/sh

EMBY_PATH="/opt/emby-server/"

# Stop emby
systemctl stop emby-server

chmod +x ./ilasm
chmod +x ./ildasm
mkdir ./tmp && cd ./tmp

#Patch web client
../ildasm $EMBY_PATH/system/Emby.Web.dll -out=Emby.Web.dll
sed -i 's/mb3admin.com/tsumo.cf/g' Emby.Web.dashboard_ui.modules.emby_apiclient.connectionmanager.js
../ilasm -dll Emby.Web.dll -out=$EMBY_PATH/system/Emby.Web.dll
rm Emby.Web.*

sed -i 's/mb3admin.com/tsumo.cf/g' $EMBY_PATH/system/dashboard-ui/embypremiere/embypremiere.js

# Patch internal (that breaks media libraries, need a workaround)
# /patch/ildasm /app/emby/Emby.Server.Implementations.dll -out=Emby.Server.Implementations.dll
#sed -i 's/\/mb3admin.com/\/tsumo.cf/g' Emby.Server.Implementations.dll
# /patch/ilasm -dll Emby.Server.Implementations.dll -out=/app/emby/Emby.Server.Implementations.dll

cat ../emby.crt >> $EMBY_PATH/etc/ssl/certs/ca-certificates.crt

# Delete tmp
cd ../ && rm -rf tmp

# Start emby
systemctl start emby-server