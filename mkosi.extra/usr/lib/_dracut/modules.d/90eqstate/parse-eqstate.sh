#!/bin/sh

for arg in $(cat /proc/cmdline); do
    case "$arg" in
        rd.eqstate.label=*)
            export EQSTATE_LABEL="${arg#rd.eqstate.label=}"
            ;;
        rd.eqstate.mount=*)
            export EQSTATE_MOUNT="${arg#rd.eqstate.mount=}"
            ;;
        rd.eqstate=0)
            export EQSTATE_SKIP=1
            ;;
    esac
done

export EQSTATE_LABEL="${EQSTATE_LABEL:-eQ}"
export EQSTATE_MOUNT="${EQSTATE_MOUNT:-/eQ}"