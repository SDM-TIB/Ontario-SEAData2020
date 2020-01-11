#!/bin/bash
docker_name="prohde_sea_ontario"

timestamp() {
  date +%Y-%m-%dT%H-%M-%S
}

run_ontario() {
  resfolder=$1
  resfile=$2
  errfile=$3
  alpha=$4
  beta=$5

  docker run -d --name $docker_name \
    -v /data/prohde/sea2020:/data \
    prohde/ontario:sea2020

  sleep 5s

  docker exec -it $docker_name bash \
    -c "/data/configuration/runDiefQueries.sh /data/queries /data/configuration/semdl-lslod.json $resfolder $resfile $errfile False 'SOURCE_SPECIFIC_HEURISTICS' $alpha $beta"

    docker stop $docker_name
    docker rm $docker_name
    sleep 1s
}

echo "$(timestamp) - preparations for experiment without indexes"
docker-compose -f datasources/mysql/docker-compose.yml start
sleep 10s
cp configuration/no-indexes.json configuration/indexes.json

echo "$(timestamp) - no index + no delay"
run_ontario /data/results/woidx_nodelay /data/results/res_woidx_nodelay.tsv /data/results/err_woidx_nodelay.txt 1 0

echo "$(timestamp) - no index + gamma 1"
run_ontario /data/results/woidx_gamma1 /data/results/res_woidx_gamma1.tsv /data/results/err_woidx_gamma1.txt 1 0.3

echo "$(timestamp) - no index + gamma 2"
run_ontario /data/results/woidx_gamma2 /data/results/res_woidx_gamma2.tsv /data/results/err_woidx_gamma2.txt 3 1

echo "$(timestamp) - no index + gamma 3"
run_ontario /data/results/woidx_gamma3 /data/results/res_woidx_gamma3.tsv /data/results/err_woidx_gamma3.txt 3 1.5

echo "$(timestamp) - preparations for experiment with indexes"
docker-compose -f datasources/mysql/docker-compose.yml restart
sleep 10s
cp configuration/rdb-indexes.json configuration/indexes.json

echo "$(timestamp) - index + no delay"
run_ontario /data/results/nodelay /data/results/res_nodelay.tsv /data/results/err_nodelay.txt 1 0

echo "$(timestamp) - index + gamma 1"
run_ontario /data/results/gamma1 /data/results/res_gamma1.tsv /data/results/err_gamma1.txt 1 0.3

echo "$(timestamp) - index + gamma 2"
run_ontario /data/results/gamma2 /data/results/res_gamma2.tsv /data/results/err_gamma2.txt 3 1

echo "$(timestamp) - index + gamma 3"
run_ontario /data/results/gamma3 /data/results/res_gamma3.tsv /data/results/err_gamma3.txt 3 1.5

echo "$(timestamp) - EXPERIMENT DONE"
