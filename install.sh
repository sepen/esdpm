#!/bin/sh

[ -z ${PREFIX} ] && PREFIX=/opt
[ -z ${BINDIR} ] && BINDIR=${PREFIX}/bin
[ -z ${DATADIR} ] && DATADIR=${PREFIX}/esdpm

if [ $(id -u) -ne 0 ]; then
  echo "You need root privileges to run this script"
  exit 1
fi

if [ ! -f esdpm.bash ]; then
  echo "Error: esdpm.bash not found"
  exit 1
fi

echo "Installing esdpm to ${BINDIR}/esdpm"
sed "s|ESDPM_BASE_DIR=.*|ESDPM_BASE_DIR=${DATADIR}|" esdpm.bash > esdpm
install -D -m 0755 esdpm ${BINDIR}/esdpm
rm -f esdpm
echo "Installing data files to ${DATADIR}"
install -d -m 0755 ${DATADIR}
cp -r hooks ${DATADIR}
