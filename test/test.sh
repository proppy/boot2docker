set -ex

GIT=$(git describe)
TMPDIR=$(mktemp -d)
cp -R base ${TMPDIR}/
cp -R rootfs ${TMPDIR}/
cp -R boot2docker ${TMPDIR}/
sed -i "s/FROM\ steeve\/boot2docker\-base/FROM\ boot2docker\/base\:${GIT}/" ${TMPDIR}/rootfs/Dockerfile
docker build -t boot2docker/base:${GIT} ${TMPDIR}/base/
docker build -t boot2docker/rootfs:${GIT} ${TMPDIR}/rootfs/
docker rm build-boot2docker-${GIT}
docker run --privileged -name build-boot2docker-${GIT} boot2docker/rootfs:${GIT}
docker cp build-boot2docker-${GIT}:/boot2docker.iso ${TMPDIR}/
echo ${TMPDIR}/boot2docker.iso

