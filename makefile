IGRAPH_SUPPORT = 1

CXX = g++
CXXFLAGS = -Wall -O3 -fopenmp 
LDFLAGS =
OBJS = prpack_utils.o \
    prpack_base_graph.o \
    prpack_preprocessed_ge_graph.o \
    prpack_preprocessed_gs_graph.o \
    prpack_preprocessed_schur_graph.o \
    prpack_preprocessed_scc_graph.o \
    prpack_solver.o \
    prpack_result.o \
    prpack_driver.o \
    prpack_driver_benchmark.o
PROG = prpack_driver

ifeq ($(IGRAPH_SUPPORT),1)
	OBJS += prpack_igraph_graph.o
	CXXFLAGS += $(shell pkg-config igraph --cflags)
	LDFLAGS += $(shell pkg-config igraph --libs)
endif

all: ${PROG}
	
${PROG}: ${OBJS}
	${CXX} ${CXXFLAGS} -o $@ ${OBJS} ${LDFLAGS}
	
test: $(PROG)
	./prpack_driver data/jazz.smat --output=- 2>/dev/null | \
	  python test/checkprvec.py data/jazz.smat -
	./prpack_driver data/jazz.smat --output=- -m sgs 2>/dev/null | \
	  python test/checkprvec.py data/jazz.smat -
	./prpack_driver data/jazz.smat --output=- -m sccgs 2>/dev/null| \
	  python test/checkprvec.py data/jazz.smat - 
	  
perf: $(PROG)
	./prpack_driver ?

matlab:	
	cd matlab; make

clean:
	$(RM) *.o ${PROG}
	

.PHONY: all clean test matlab
