CC ?= gcc
CFLAGS += -fPIC

C_SRCS = picoacph.c picoapi.c picobase.c picocep.c picoctrl.c picodata.c picodbg.c picoextapi.c picofftsg.c picokdbg.c picokdt.c picokfst.c picoklex.c picoknow.c picokpdf.c picokpr.c picoktab.c picoos.c picopal.c picopam.c picopr.c picorsrc.c picosa.c picosig.c picosig2.c picospho.c picotok.c picotrns.c picowa.c
C_OBJS = $(C_SRCS:%.c=%.o)
HEADERS = picoacph.h picoapi.h picoapid.h picobase.h picocep.h picoctrl.h picodata.h picodbg.h picodefs.h picodsp.h picoextapi.h picofftsg.h picokdbg.h picokdt.h picokfst.h picoklex.h picoknow.h picokpdf.h picokpr.h picoktab.h picoos.h picopal.h picopam.h picopltf.h picopr.h picorsrc.h picosa.h picosig.h picosig2.h picospho.h picotok.h picotrns.h picowa.h

all: libpico.a
	@echo "Done building."

clean:
	rm -f libpico.a *.o

%.o: %.c $(HEADERS)

libpico.a: $(C_OBJS)
	$(AR) rcs $@ $^
	$(RANLIB) $@
