#!/bin/bash

cd /var/lib/myfrdcsa/codebases/minor && gith changes_since_yesterday_ls
cd /var/lib/myfrdcsa/codebases/releases && gith changes_since_yesterday_ls
cd /var/lib/myfrdcsa/codebases/minor/fcms/FCMS && gith changes_since_yesterday_ls
cd /var/lib/myfrdcsas/versions/myfrdcsa-1.1 && gith changes_since_yesterday_ls

cd /$HOME/.myconfig-private && gith changes_since_yesterday_ls
