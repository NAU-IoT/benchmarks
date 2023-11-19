#CC		= g++-10

# USE G++-10 for baremetal testing, G++-12 for Docker use
ifeq ($(shell command -v g++-12 2>/dev/null),)
	CC = g++-10
else
	CC = g++-12
endif

FLGS 	= -std=c++20 -march=native -pg -g -Wall -Wextra -pedantic -Wno-unused-result -Wparentheses -Wsign-compare
PROJDIR = $(realpath $(CURDIR))
SRCDIR	= $(PROJDIR)/src
CPP		= $(shell find $(PROJDIR)/src -name '*.cpp')
CUDA	= $(shell find $(PROJDIR)/src -name '*.cu')
SRC 	= benchmark.cpp $(CPP) -lpthread
BIN 	= benchsys

bench:
	${CC} ${FLGS} ${SRC} -o ${BIN}

run_bench:
	./${BIN} -b

run_daemon:
	./${BIN} -d

gprof:
	gprof ${BIN} gmon.out > gprof.txt

callgrind:
	valgrind --tool=callgrind ./${BIN}
	#callgrind_annotate callgrind.out

flamegraph:
	sudo perf record -g ./${BIN}
	sudo perf script | sudo ../FlameGraph/stackcollapse-perf.pl | sudo ../FlameGraph/flamegraph.pl > rpi.svg

docker_img:
	sudo docker build . -t benchmarks

docker_run:
	sudo docker run --privileged -it benchmarks:latest /bin/bash

gpu_docker_img:
	sudo nvidia-docker build . -t benchmarks

gpu_docker_run:
	sudo nvidia-docker run --privileged -it benchmarks:latest /bin/bash

avail_macros:
	gcc -dM -E - </dev/null

install:
	mv ${BIN} /usr/bin

uninstall:
	rm -f /usr/bin/${BIN}

clean:
	rm -f ${BIN}
	rm -f *.txt
	rm -f *.out
	rm -f *.data*
	rm -f *perf
	rm -f *.csv
