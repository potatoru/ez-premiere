#!/bin/sh

EMBY_PATH="/opt/emby-server/"

# Stop emby
systemctl stop emby-server

chmod +x ./ilasm
chmod +x ./ildasm
mkdir ./tmp && cd ./tmp

#Patch web client
../ildasm $EMBY_PATH/system/Emby.Web.dll -out=Emby.Web.dll
sed -i 's#ajax({url:"https://mb3admin.com/admin/service/registration/validateDevice?"+new URLSearchParams(params).toString(),type:"POST",dataType:"json"})#Promise.resolve(new Response('"'"'{"cacheExpirationDays":365,"message":"Device Valid","resultCode":"GOOD"}'"'"').json())#g' Emby.Web.dashboard_ui.modules.emby_apiclient.connectionmanager.js
../ilasm -dll Emby.Web.dll -out=$EMBY_PATH/system/Emby.Web.dll
rm Emby.Web.*

sed -i 's#fetch("https://mb3admin.com/admin/service/registration/getStatus",{method:"POST",body:key,headers:{"Content-Type":"application/x-www-form-urlencoded"}}).then(function(response){return response.json()})#Promise.resolve('"'"'{"planType":"Lifetime","deviceStatus":0,"subscriptions":[]}'"'"')#g' $EMBY_PATH/system/dashboard-ui/embypremiere/embypremiere.js

# Delete tmp
cd ../ && rm -rf tmp

# Start emby
systemctl start emby-server
