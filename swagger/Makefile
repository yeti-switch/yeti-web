dest=${DESTDIR}/swagger
spec=yeti.json


all: ${spec}

${spec}: yeti_api.yml yeti.j2 helpers.j2
	./render.py yeti_api.yml yeti.j2 ${version} > ${spec} || rm -f ${spec}

install: ${spec} dist
	install -d ${dest}
	cp -rv dist/* ${dest}
	install -m0644 ${spec} ${dest}

clean:
	rm -f ${spec}
