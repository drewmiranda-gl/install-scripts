#!/bin/bash

ssh drew@<hostname> "
rm -f file.sh \
    && wget file.sh \
    && sudo bash file.sh
"
