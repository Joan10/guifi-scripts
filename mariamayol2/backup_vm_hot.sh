#!/bin/bash

########################
#
# Generam un backup en calent de la maquina virtuals passada. Aquest backup es guarda a /data/disc1/backups/MV/ classificat
# per data. 
#
# El procediment per fer el backup en calent es:
# a) Estat inicial
#    SNAPSHOT0(A) <- SNAPSHOT1(A)
#    L'snapshot actual corre sobre la base. SNAPSHOT0 existeix nomes si hi ha un snapshot i una base ja en marxa.
# b) blockpull 
#    SNAPSHOT0 - SNAPSHOT1(A)
#    Es deixa l'SNAPSHOT1 com a Base i actiu. L'SNAPSHOT0 deixa d'estar operatiu.
# c) snapshot create as
#    SNAPSHOT0 - SNAPSHOT1(A) <- SNAPSHOT2(A)
#    Es crea snapshot2, que està actiu i depèn d'snapshot1 com a base.
# d) blockpull
#    SNAPSHOT0 - SNAPSHOT1 - SNAPSHOT2(A)
#    SNAPSHOT 1 deixa d'estar operatiu i pot ser copiat
#
# Es mes senzill emprar la comanda blockcommit, pero sembla que te algun bug i dona error en executar-la
#
############################

mon=$1
interactive="false"
if [ "$2" == "i" ]; then
	interactive="true"
elif [ "$2" == "o" ]; then
	interactive="false"
else
	exit -1
fi

#http://wiki.libvirt.org/page/Live-merge-an-entire-disk-image-chain-including-current-active-disk

if [ -z "$3" ]; then
	nam=`virsh domblklist $mon | grep -i $mon | cut -c1-3`
else
	nam=$3
fi

bck_file=`virsh domblklist $mon | grep -i $mon | cut -c4- | sed -e "s/ //g"`

if [ "$interactive" == "true" ]; then 
	echo $nam
	echo $bck_file
	echo 'virsh snapshot-create-as --domain '$mon' _'`date +%Y-%m-%dT%H_%M_%S`' --disk-only --atomic'
	echo "Pitja per continuar"
	read
fi

virsh blockpull $mon $nam --wait --verbose

virsh snapshot-create-as --domain $mon `date +%Y-%m-%dT%H_%M_%S` --disk-only --atomic
if [ "$interactive" == "true" ]; then 
	echo 'virsh blockpull $mon $nam --wait --verbose'
	echo "Pitja per continuar"
	read
fi
virsh blockpull $mon $nam --wait --verbose
if [ "$interactive" == "true" ]; then 
	echo 'gzip $bck_file'
	echo "Pitja per continuar"
	read
fi
gzip $bck_file
rsync -a  "$bck_file".gz /data/disc1/backups/MV/$mon/backup_"$mon"_`date +%Y-%m-%dT%H_%M_%S`.gz

rm "$bck_file".gz

# Esborram backups antics
cd /data/disc1/backups/MV/$mon/
ls -1 -t | tail -n +6 | xargs rm > /dev/null 2>&1
