#!/bin/sh
for arg in $(cat /proc/cmdline); do
    case $arg in
        rd.eqstate.label=*)   EQSTATE_LABEL=${arg#rd.eqstate.label=} ;;
        rd.eqstate.mount=*)   EQSTATE_MOUNT=${arg#rd.eqstate.mount=} ;;
        rd.eqstate=0)         EQSTATE_SKIP=1 ;;
    esac
done
EQSTATE_LABEL=${EQSTATE_LABEL:-eQ}
EQSTATE_MOUNT=${EQSTATE_MOUNT:-/eQ}