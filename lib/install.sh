mkdir /build && \
cd /build && \
tar zxvf /home/application/current/lib/ttf2eot-0.0.2-2.tar.gz && \
sed -i.bak "/using std::vector;/ i\#include <cstddef>" /build/ttf2eot-0.0.2-2/OpenTypeUtilities.h && \
cd /build/ttf2eot-0.0.2-2 && \
make && \
cp ttf2eot /usr/local/bin/ttf2eot

## ttfautohint build
cd /build && \
tar zxvf /home/application/current/lib/ttfautohint-0.95.tar.gz && \
cd /build/ttfautohint-0.95 && \
./configure --with-qt=no --without-doc && \
make && \
make install