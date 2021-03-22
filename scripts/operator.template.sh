#!/bin/bash

# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

if [ ${ol} = 8 ]; then
  dnf -y upgrade --security
else
  yum -y -t update --security
fi

sed -i -e "s/autoinstall\s=\sno/autoinstall = yes/g" /etc/uptrack/uptrack.conf
uptrack-upgrade -y
pip3 install oci-cli