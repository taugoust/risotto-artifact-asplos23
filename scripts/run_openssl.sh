#!/usr/bin/env bash

NR_RUNS=${NR_RUNS:=10}
OUTPUT=${OUTPUT:=results/openssl.csv}

TASKSET="taskset -c 0-111"

####################################

# Reset scaling governor to schedutil on exit
trap "echo schedutil | sudo tee /sys/devices/system/cpu/cpufreq/policy*/scaling_governor" EXIT

# Set scaling governor to 'performance' (max frequency all the time)
echo performance | sudo tee /sys/devices/system/cpu/cpufreq/policy*/scaling_governor


# Run all benchmarks natively (aarch64) and with some QEMU variants
benchmarks=(md5 sh1 sha256 rsa)
for b in ${benchmarks[@]}; do 
    # native
    ${TASKSET} ./a2a-benchmarks/bench.py  -b openssl.${b} -d native -r native -o ${OUTPUT} -a aarch64 -n $(nproc) -i ${NR_RUNS} -t native -c configs/native.config -vvv

    # QEMUs
    ${TASKSET} ./a2a-benchmarks/bench.py -b openssl.${b} -d native -r qemu -o ${OUTPUT} -a x86_64 -n $(nproc) -i ${NR_RUNS} -t qemu -c configs/qemu.config -vvv
    ${TASKSET} ./a2a-benchmarks/bench.py -b openssl.${b} -d native -r qemu --run-opt='-nlib configs/nlib/openssl.nmi' -o ${OUTPUT} -a x86_64 -n $(nproc) -i ${NR_RUNS} -t risotto -c configs/risotto.config -vvv
done
