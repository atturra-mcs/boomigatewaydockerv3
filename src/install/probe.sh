#!/bin/bash

readonly JMXTERM_JAR="/opt/jmxutil/jmxterm.jar"
readonly LIVENESS_PROBE_TYPE="liveness"
readonly READINESS_PROBE_TYPE="readiness"
readonly STARTUP_PROBE_TYPE="startup"

main() {
    local probe_type="$1"

    # Validate that the probe type is valid
    if [[ -z "${probe_type}" ||
       ( "${probe_type}" != "${LIVENESS_PROBE_TYPE}" && "${probe_type}" != "${READINESS_PROBE_TYPE}" &&
         "${probe_type}" != "${STARTUP_PROBE_TYPE}" ) ]]; then
        usage
        exit 1
    fi

    execute_probe_check "${probe_type}"
}

usage() {
    echo "usage: $0 <probe_type>"
    echo "    Executes a JMX call to determine the health of the container based on the probe type"
    echo ""
    echo "arguments:"
    echo "    <probe_type>        the name of the probe, one of:"
    echo "                            - liveness"
    echo "                            - readiness"
    echo "                            - startup"
}

execute_probe_check() {
    local probe_type=$1

    local pid=$(get_pid)

    # We know the JMX call is not possible if there isn't even a PID
    if [[ -z "${pid}" ]]; then
        exit 1
    fi

    local is_ready_for_work=$(is_container_ready_for_work "${pid}")
    if [[ "${probe_type}" = "${LIVENESS_PROBE_TYPE}" ]]; then
        liveness_probe_check "${is_ready_for_work}"
    else
        readiness_startup_probe_check "${is_ready_for_work}"
    fi
}

liveness_probe_check() {
    local is_ready_for_work=$1
    if [[ "${is_ready_for_work}" = "true" || "${is_ready_for_work}" = "false" ]]; then
        exit 0
    else
        echo "Can't get status for node"
        exit 1
    fi
}

readiness_startup_probe_check() {
    local is_ready_for_work=$1
    if [[ "${is_ready_for_work}" = "true" ]]; then
        echo "Ready for work"
        exit 0
    else
        echo "Not ready for work"
        exit 1
    fi
}

get_pid() {
    echo $(pgrep -f "com.boomi.container.core.Container")
}

is_container_ready_for_work() {
    local pid=$1
    echo $(su - boomi -c "echo get -s -b com.boomi.container.services:type=ContainerController ReadyForWork | "${JAVA_HOME}"/bin/java --add-exports jdk.jconsole/sun.tools.jconsole=ALL-UNNAMED -jar "${JMXTERM_JAR}" -e -n -v error_only -l "${pid}"")
}

main "$@"