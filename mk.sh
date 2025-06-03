#./build-custom-images.sh
./build-image.sh

#./instant project down --env-file .env
#./instant project destroy --env-file .env
#./instant project init --env-file .env

#nfs

#openhim

#./instant package remove -n interoperability-layer-openhim --env-file .env
#./instant package init -n interoperability-layer-openhim --env-file .env

#./instant package down -n interoperability-layer-openhim --env-file .env
#./instant package up -n interoperability-layer-openhim --env-file .env -d

# reverse proxy
#./instant package remove -n reverse-proxy-nginx --env-file .env
#./instant package init -n reverse-proxy-nginx --env-file .env
# ./instant package down -n reverse-proxy-nginx --env-file .env
# ./instant package up -n reverse-proxy-nginx --env-file .env


#mysql 

#./instant package remove -n database-mysql --env-file .env
./instant package init -n database-mysql --env-file .env
# ./instant package down -n database-mysql --env-file .env
# ./instant package up -n database-mysql --env-file .env -d

#isanteplus
./instant package remove -n emr-isanteplus --env-file .env 
./instant package init -n emr-isanteplus --env-file .env 
# ./instant package down -n emr-isanteplus --env-file .env
#./instant package up -n emr-isanteplus --env-file .env

# #opencr
#./instant package remove -n client-registry-opencr --env-file .env
#./instant package init -n client-registry-opencr --env-file #.env
#./instant package down -n client-registry-opencr --env-file .env
#./instant package up -n client-registry-opencr --env-file .env

#monitroing
#./instant package remove -n monitoring --env-file .env
#./instant package init -n monitoring --env-file .env
#./instant package down -n monitoring --env-file .env
#./instant package up -n monitoring --env-file .env

#data pipeline
# ./instant package remove -n data-pipeline-isanteplus --env-file .env
#./instant package init -n data-pipeline-isanteplus --env-file .env
#./instant package down -n data-pipeline-isanteplus --env-file .env
#./instant package up -n data-pipeline-isanteplus --env-file .env

#openhim-mediator-openxds 
#./instant package remove -n openhim-mediator-openxds --env-file .env
#./instant fpackage init -n openhim-mediator-openxds --env-file .env
#./instant package down -n openhim-mediator-openxds --env-file .env
#./instant package up -n openhim-mediator-openxds --env-file .env





