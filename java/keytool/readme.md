# Keytool

https://docs.oracle.com/en/java/javase/17/docs/specs/man/keytool.html

# Arguments

Argument | Description
---- | ----
`-keystore` | Specify keystore. e.g. `-keystore /path/to/keystore.jks`
`-storepass` | Keystore password. e.g. `-storepass changeit`

# Examples

## View Certs in Keystore

```sh
keytool -v -list -storepass changeit -keystore /path/to/keystore.jks
```