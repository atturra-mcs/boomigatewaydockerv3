#!/bin/bash
# Copyright (c) 2020 Boomi, Inc.

main() {
    if [[ "$#" -eq 2 ]]; then
        override_properties "$1" "$2"
    else
        override_properties "${ATOM_VMOPTIONS_OVERRIDES}" "${ATOM_HOME}/bin/atom.vmoptions"
        override_properties "${CONTAINER_PROPERTIES_OVERRIDES}" "${ATOM_HOME}/conf/container.properties"
    fi
}

override_properties() {
    local overrides="${1}"
    local file="${2}"

    # do nothing if overrides aren't set or the file to be modified does not exist
    if [[ -z "${overrides}" ]] || [[ ! -f "${file}" ]]; then
        return
    fi

    echo "Overriding values in "${file}""

    # split on '|' char and loop through the properties
    while IFS='|' read -a properties || [[ -n "${properties}" ]]; do
        for property in "${properties[@]}"; do
            # first, let's handle any special cases
            local is_handled=$(handle_special_properties "${property}" "${file}")
            if [[ "${is_handled}" = "success" ]]; then
                # no need to continue with the default logic for this property since this property
                # has already been handled.
                continue
            fi

            # check if property contains the '=' char
            if [[ "${property}" = *"="* ]]; then
                # extract substring up until the '=' character in the property
                local property_key="${property%%=*}"

                # then delete the property in the file in case it exists
                sed -ci "/"${property_key}"=/d" "${file}"
            fi

            # and finally append it to the file
            echo "${property}" >> "${file}"
        done
    done <<< "${overrides}"
}

# Handles any properties which require special logic.
# Echoes "success" if the property has been handled (to simulate a return value).
handle_special_properties() {
    local property="${1}"
    local file="${2}"

    # if the new property starts with "-Xmx", then remove the default -Xmx property and append the new property.
    if [[ "${property}" = "-Xmx"* ]]; then
        sed -ci '/-Xmx/d' "${file}"
        echo "${property}" >> "${file}"
        echo "success"
    fi
}

main "$@"