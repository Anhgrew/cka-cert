#! /bin/bash

kubectl exec -it mysql-client -n elearning -- mysql -h mysql -u root -p

kubectl create secret -n elearning generic application --from-file application.properties
