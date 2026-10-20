# Lock a package to prevent it from being updated

```sh
sudo apt-mark hold package-name
```

View existing holds

```sh
apt-mark showhold
```

Remove package hold

```sh
sudo apt-mark unhold package-name
```