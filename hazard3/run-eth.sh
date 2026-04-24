#! /bin/sh

echo 'please verify that tap0 is created  sudo ./example_soc/libfpga/ethernet/create_tap_iface.sh'
PATH=$PATH:/home/laur/lucru/cn/riscv/rvsoc-site-japan/buildroot-2021.08-5.13/output/host/bin

set -x
set -e
cd /home/laur/lucru/cn/riscv/rvsoc-site-japan/initmem_gen2
./run-nuttx.sh
cd -
cp /home/laur/lucru/cn/riscv/rvsoc-site-japan/initmem_gen2/init_kernel.txt init_kernel.txt
cp /home/laur/lucru/cn/riscv/rvsoc-site-japan/initmem_gen2/initmem.bin initmem.bin

make veriwt
#./simv

