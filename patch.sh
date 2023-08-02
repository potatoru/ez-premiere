#!/bin/sh

EMBY_PATH="/opt/emby-server/"

# Stop emby
systemctl stop emby-server

chmod +x ./ilasm
chmod +x ./ildasm
mkdir ./tmp && cd ./tmp

#Patch web client
../ildasm $EMBY_PATH/system/Emby.Web.dll -out=Emby.Web.dll
sed -i 's#ajax({url:"https://mb3admin.com/admin/service/registration/validateDevice?"+paramsToString(params),type:"POST",dataType:"json"})#Promise.resolve(new Response('"'"'{"cacheExpirationDays":365,"message":"Device Valid","resultCode":"GOOD"}'"'"').json())#g' Emby.Web.dashboard_ui.modules.emby_apiclient.connectionmanager.js
../ilasm -dll Emby.Web.dll -out=$EMBY_PATH/system/Emby.Web.dll
rm Emby.Web.*

# TODO
# sed -i 's/mb3admin.com/tsumo.cf/g' $EMBY_PATH/system/dashboard-ui/embypremiere/embypremiere.js

# Delete tmp
cd ../ && rm -rf tmp

# Start emby
systemctl start emby-server
