#!/usr/bin/env bash

pushd /usr/share/landoop/sample-data

# shellcheck source=variables.env
source variables.env

# Create Topics
# shellcheck disable=SC2043
for key in 3; do
    # Create topic with x partitions and a retention size of 50MB, log segment
    # size of 20MB and compression type y.
    kafka-topics \
        --zookeeper localhost:2181 \
        --topic "${TOPICS[key]}" \
        --partitions "${PARTITIONS[key]}" \
        --replication-factor 1 \
        --config retention.bytes=26214400 \
        --config compression.type="${COMPRESSION[key]}" \
        --config segment.bytes=8388608 \
        --create
done

# Insert data with text key converted to json key
# shellcheck disable=SC2043
for key in 3; do
    /usr/local/bin/normcat -r "${RATES[key]}" -j "${JITTER[key]}" -p "${PERIOD[key]}" -c -v "${DATA[key]}" | \
        sed -r -e 's/([A-Z0-9-]*):/{"model":"\1"}#/' | \
        kafka-console-producer \
            --broker-list localhost:9092 \
            --topic "${TOPICS[key]}" \
            --property parse.key=true \
            --property "key.separator=#"
done

popd
