NULL = 
ACLOCAL_AMFLAGS = -I m4
.PHONY: check

noinst_LTLIBRARIES = \
	libhooking.la \
	$(NULL)

libhooking_la_SOURCES = \
	hooking.vala \
	api.vala \
	rngen.vala \
	serializables.vala \
	$(NULL)

libhooking_la_VALAFLAGS = \
	-H hooking.h \
	--library hooking \
	--vapidir $(GEE_PREFIX)/share/vala/vapi \
	--vapidir $(JSON_PREFIX)/share/vala-0.32/vapi \
	--vapidir $(TASKLETSYSTEM_VAPIDIR) \
	--vapidir $(NTKDCOMMON_VAPIDIR) \
	--vapidir $(NTKDRPC_VAPIDIR) \
	--pkg gee-0.8 \
	--pkg json-glib-1.0 \
	--pkg tasklet-system \
	--pkg ntkd-common \
	--pkg ntkdrpc\
	$(NULL)

libhooking_la_CPPFLAGS = \
	-w \
	$(GOBJECT_CFLAGS) \
	$(GEE_CFLAGS) \
	$(JSONGLIB_CFLAGS) \
	$(TASKLETSYSTEM_CFLAGS) \
	$(NTKDCOMMON_CFLAGS) \
	$(NTKDRPC_CFLAGS) \
	$(NULL)

libhooking_la_LIBADD = \
	$(GOBJECT_LIBS) \
	$(GEE_LIBS) \
	$(JSONGLIB_LIBS) \
	$(TASKLETSYSTEM_LIBS) \
	$(NTKDCOMMON_LIBS) \
	$(NTKDRPC_LIBS) \
	$(NULL)

MAINTAINERCLEANFILES = \
	$(srcdir)/hooking.vapi \
	$(NULL)

hooking.vapi: libhooking_la_vala.stamp
	$(NULL)

