# Validate

## Cert (Public key) and Private key pair together

```sh
CERT_PUB=/opt/tls/cert.crt
CERT_KEY=/opt/tls/cert.key
diff <(openssl rsa -modulus -noout -in ${CERT_KEY} | openssl md5) <(openssl x509 -modulus -noout -in ${CERT_PUB} | openssl md5) && echo Public and Private key validated and match.
```

## CA and Cert pair together

````sh
CERT_PUB=/opt/tls/cert.crt
CERT_CA=/opt/tls/ca.crt
openssl verify -CAfile ${CERT_CA} ${CERT_PUB} || echo "ERROR! Cert not signed by specified CA"
```