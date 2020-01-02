FROM open-liberty

COPY src/main/liberty/config /config/
RUN configure.sh
COPY target/inventory.war /config/apps 