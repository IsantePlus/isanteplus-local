#./build-custom-images.sh
./build-image.sh

#./instant project down --env-file .env
#./instant project destroy --env-file .env
#./instant project init --env-file .env

#reverse proxy
# ./instant package remove -n reverse-proxy-nginx --env-file .env
# ./instant package init -n reverse-proxy-nginx --env-file .env
# ./instant package down -n reverse-proxy-nginx --env-file .env
# ./instant package up -n reverse-proxy-nginx --env-file .env

#openhim

# ./instant package remove -n interoperability-layer-openhim --env-file .env
# ./instant package init -n interoperability-layer-openhim --env-file .env -d
# ./instant package down -n interoperability-layer-openhim --env-file .env
# ./instant package up -n interoperability-layer-openhim --env-file .env -d

#mysql 

./instant package remove -n database-mysql --env-file .env
./instant package init -n database-mysql --env-file .env -d
# ./instant package down -n database-mysql --env-file .env
# ./instant package up -n database-mysql --env-file .env

# #isanteplus
./instant package remove -n emr-isanteplus --env-file .env
./instant package init -n emr-isanteplus --env-file .env -d
#./instant package down -n emr-isanteplus --env-file .env
#./instant package up -n emr-isanteplus --env-file .env

# 172.31.2.125
