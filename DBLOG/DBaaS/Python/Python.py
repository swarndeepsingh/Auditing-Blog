import requests
import json

#uri='https://itopuat.ebix.com/webservices/rest.php?version=1.3&auth_pwd=102Ebix29%23&auth_user=swarndeep.singh&json_data={"operation": "core/create","comment": "From Database As A Service.",   "class": "UserRequest",   "output_fields": "id, friendlyname",   "fields":   {      "org_id": "SELECT Organization WHERE name = \"globalsql\"", "title": "Houston, got a problem!",      "description": "The fridge is empty",     "caller_id": {         "name": "singh",         "first_name": "swarndeep"      }    }}'

uri='https://itopuat.ebix.com/webservices/rest.php?version=1.3&auth_pwd=102Ebix29%23&auth_user=swarndeep.singh&json_data={"operation": "core/create","comment": "From Database As A Service.",   "class": "UserRequest",   "output_fields": "id, friendlyname",   "fields":   {      "org_id": "SELECT Organization WHERE name = \'EBIX\'", "title": "Houston, got a problem!",      "description": "The fridge is empty"    }}'

#uri='https://itopuat.ebix.com/webservices/rest.php?version=1.3&auth_pwd=102Ebix29%23&auth_user=swarndeep.singh&json_data={   "operation": "core/get",   "class": "Person",   "key": 1,   "output_fields": "*"}'

 
#print(uri);

response=requests.post(uri);

print(response.content);

