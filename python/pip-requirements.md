# Install

```sh
sudo apt install -y python3-pip
sudo python3 -m pip install pipreqs
```

# Generate PIP Requirements.txt

```sh
python3 -m  pipreqs.pipreqs --encoding utf-8 ./
```

# Install requirements from Requirements.txt

```sh
python3 -m pip install -r requirements.txt
```

Optionally, you can use the following:

* `--ignore-installed`
    * Ignore the installed packages
* `--force-reinstall`
    * Reinstall all packages even if they are already up-to-date.
