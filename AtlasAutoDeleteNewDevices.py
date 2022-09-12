#!/usr/bin/python3

username = 'abc@gmail.com'
password = 'pass1234'
login_url = 'https://discovery.pokemod.dev/atlas/auth/user/login'

import requests
s = requests.Session()
s.headers.update({'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:104.0) Gecko/20100101 Firefox/104.0'})
s.headers.update({'Accept': 'application/json, text/plain, */*'})
s.headers.update({'Accept_language': 'en-US,en;q=0.5'})
s.headers.update({'Content-Type': 'application/json'})
options = s.request("OPTIONS", login_url, headers={"Access-Control-Request-Method": "POST", "Access-Control-Request-Headers": "content-type"})
r = s.post(login_url, json={"email":username,"password":password})
s.headers.update({"Authorization": "Bearer " + r.json()['auth_token']})
r = s.get("https://discovery.pokemod.dev/atlas/user/devices", params={"page": "1", "size": "50", "query": None})



for i in r.json()['items']:
    #{'id': 1234, 'device_name': 'city01', 'uses_own_config': False, 'license_status': 2}
    #License_status: 2 = Activated, 0 Deactivated
    if i['license_status'] == 0:
        print('License for ' + i['device_name'] + ' is not enabled')
        for n in r.json()['items']: 
            if i['device_name'] == n['device_name'] and i['id'] != n['id']:
                print('Deleting the old device beforehand')
                s.post("https://discovery.pokemod.dev/atlas/device/delete", json={"instance_id":i['id']})
        #Checking if there are enough licenses to activate it
        info = s.get("https://discovery.pokemod.dev/atlas/user/info")
        # {'total_licenses': 25, 'total_active_licenses': 25, 'used_licenses': 25, 'email': 'abc@gmail.com', 'has_customer': True}
        total_active_licenses = info.json()['total_active_licenses']
        used_licenses = info.json()['used_licenses']
        if total_active_licenses - used_licenses >= 1:
            print('Enabling a new device: ' + i['device_name'])
            s.post("https://discovery.pokemod.dev/atlas/instance/activateLicense", json={"instance_id":i['id']+1})
        else:
            print("There are not enough licenses so the device hasn't been activated")

