

## To Create a new cert
**Note**: uses the webroot method, requires nginx server to be setup with:
```
location ~ .well-known/acme-challenge/ {
    root /var/www/letsencrypt;
    default_type text/plain;
}
```
...which most AEx existing servers will already be

To get a cert
`sudo -H /opt/letsencrypt/letsencrypt-auto certonly --webroot --webroot-path /var/www/letsencrypt -d {domain-name} --email jurgensd@automationexchange.co.za`

To renew certs
`sudo /opt/letsencrypt/letsencrypt-auto renew`
