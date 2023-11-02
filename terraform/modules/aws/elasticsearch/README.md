# Security

## Kibana Setup

### Internal Users
Initial (admin) user is set up through config; with password fetched from AWS secret manager; DO NOT use this login for service credentials,

Add the _aex-service_ user (which can be used for service logins):
1. Create a user _aex-service_, intended to be used for all aex services. Store the password in 1password.
2. Create a role _data-access_ which is assigned to the built-in permission _data-access_. Also assign this role to wildcard `*` index pattern - to cover all indexes.
3. Assign _aex-service_ to this role
4. Test you can access cluster data with this user (via a REST client)

### Role Mappings
**Development**
* map the backend role _7591516b-56d8-4bdb-a20d-99b0bb17d292_ to the _kibana_user_ role. This will ensure anyone who is attached to _Data Reader - Development_ group will have read access to kibana.

**Production**
* map the backend role _c795317d-938d-4a5f-a7c4-a0728c68baa4_ to the _kibana_user_ role. This will ensure anyone who is attached to _Data Reader - Production_ group will have read access to kibana.

## SAML
After having enabled SAML in ES by setting `saml_env = "prod"` or _dev_ as appropriate (in terraform), proceed to the equivalent application in AAD (Azure Active Directory).

There are two existing SAML applications:
* AEx Development Data - for all _dev_ databases
* AEx Production Data - for _prod_ databases

In the AWS ES domain, _Security Configuration_ tab, copy:
* _Service provider entity ID_ - add it as a new entry to the AAD app's SAML _Entity ID_
* _SSO URL (service provider initiated)_ - add it as a new entry to the AAD app's SAML _Reply URL_


## How to give a User Kibana Access
Two tiers of user exists for Kibana: **administrator**, and **reader**; they are separated for production and development environments.
**Production Data**
* For **reader** permissions, assign the user in AAD to **Data Reader - Production** group
* For administrator permission, assign the user in AAD to **Data Administrator - Production** group

**Development Data**
* For **reader** permissions, assign the user in AAD to **Data Reader - Development** group
* For administrator permission, assign the user in AAD to **Data Administrator - Development** group

The next time the user signs in - they will have the correct permissions.

