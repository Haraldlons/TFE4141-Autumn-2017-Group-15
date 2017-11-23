@echo off
set xv_path=D:\\Xilinx\\Vivado\\2017.2\\bin
call %xv_path%/xelab  -wto 2e5568e20b9a4c90a0976c640f22f6d3 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot RSACoreTestBench_behav xil_defaultlib.RSACoreTestBench -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
