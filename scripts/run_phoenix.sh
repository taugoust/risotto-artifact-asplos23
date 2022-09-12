#!/usr/bin/env bash

NR_RUNS=10
TASKSET="taskset -c 0-111"

####################################

# Reset scaling governor to schedutil on exit
trap "echo schedutil | sudo tee /sys/devices/system/cpu/cpufreq/policy*/scaling_governor" EXIT

# Set scaling governor to 'performance' (max frequency all the time)
echo performance | sudo tee /sys/devices/system/cpu/cpufreq/policy*/scaling_governor


# Run all benchmarks natively (aarch64) and with all QEMU variants
benchmarks=(histogram kmeans linearregression matrixmultiply pca stringmatch wordcount)
for b in ${benchmarks[@]}; do
    # native
    ${TASKSET} ./a2a-benchmarks/bench.py  -b phoenix.$b -d large -r native -o results/results.csv -a aarch64 -n $(nproc) -i ${NR_RUNS} -t native -c configs/native.config -vvv

    # QEMUs
    for q in master-6.1.0 no-fences tcg-tso risotto; do
	${TASKSET} ./a2a-benchmarks/bench.py  -b phoenix.$b -d large -r qemu -o results/results.csv -a x86_64 -n $(nproc) -i ${NR_RUNS} -t $q -c configs/qemu-${q}.config -vvv
    done
done

