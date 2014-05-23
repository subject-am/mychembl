#!/bin/bash

## Download target prediction models
wget ftp://ftp.ebi.ac.uk/pub/databases/chembl/target_predictions/chembl_18_models.tar.gz
tar -zxf chembl_18_models.tar.gz

## Install ChEMBLdb
wget ftp://ftp.ebi.ac.uk/pub/databases/chembl/ChEMBLdb/releases/chembl_18/chembl_18_postgresql.tar.gz
tar zxf chembl_18_postgresql.tar.gz

createdb chembl_18

cd chembl_18_postgresql/
psql chembl_18 < chembl_18.pgdump.sql

echo "chemblvm" | sudo -S curl -o /etc/postgresql/9.1/main/postgresql.conf https://raw.githubusercontent.com/chembl/mychembl/master/configuration/mychembl_postgresql.conf
echo "chemblvm" | sudo -S curl -o /etc/postgresql/9.1/main/pg_hba.conf https://raw.githubusercontent.com/chembl/mychembl/master/configuration/mychembl_pg_hba.conf
echo "chemblvm" | sudo -S curl -o /etc/sysctl.conf https://raw.githubusercontent.com/chembl/mychembl/master/configuration/mychembl_sysctl.conf

echo "chemblvm" | sudo -S service postgresql restart

psql --username=chembl -d chembl_18 -c "create user foo password 'secret';"
psql --username=chembl -d chembl_18 -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO mychembl;"

psql --username=chembl -d chembl_18 -c "create extension rdkit;"
wget https://raw.githubusercontent.com/chembl/mychembl/master/indexes.sql
psql --username=chembl -d chembl_18 -a -f indexes.sql
