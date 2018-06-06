##############
# UBER OPTS  #
##############

CUSTOM_FLAGS := -O3 -g0 -DNDEBUG

ifneq ($(LOCAL_SDCLANG_LTO),true)
  ifeq ($(my_clang),true)
    ifndef LOCAL_IS_HOST_MODULE
      CUSTOM_FLAGS += -fuse-ld=qcld
    else
      CUSTOM_FLAGS += -fuse-ld=gold
    endif
  else
    CUSTOM_FLAGS += -fuse-ld=gold
  endif
else
  CUSTOM_FLAGS := -O3 -g0 -DNDEBUG
endif

##################
# ArchiDroid GCC #
##################

ARCHI_FLAGS := -fgcse-las -fgcse-sm -fipa-pta -fivopts -fomit-frame-pointer -frename-registers -fsection-anchors -ftracer -ftree-loop-im -ftree-loop-ivcanon -funsafe-loop-optimizations -funswitch-loops -fweb -fgraphite -fgraphite-identity -floop-strip-mine -floop-nest-optimize -floop-parallelize-all -Wno-error=array-bounds -Wno-error=clobbered -Wno-error=maybe-uninitialized -Wno-error=strict-overflow
CUSTOM_FLAGS += $(ARCHI_FLAGS)

ifeq ($(my_clang),true)
  CUSTOM_FLAGS := $(filter-out $(ARCHI_FLAGS),$(CUSTOM_FLAGS))
endif

O_FLAGS := -O3 -O2 -Os -O1 -O0 -Og -Oz

# Remove all flags we don't want use high level of optimization
my_cflags := $(filter-out -Wall -Werror -g -Wextra -Weverything $(O_FLAGS),$(my_cflags)) $(CUSTOM_FLAGS)
my_cppflags := $(filter-out -Wall -Werror -g -Wextra -Weverything $(O_FLAGS),$(my_cppflags)) $(CUSTOM_FLAGS)
my_conlyflags := $(filter-out -Wall -Werror -g -Wextra -Weverything $(O_FLAGS),$(my_conlyflags)) $(CUSTOM_FLAGS)

#######
# IPA #
#######

LOCAL_DISABLE_IPA := \
	libbluetooth_jni \
	bluetooth.mapsapi \
	bluetooth.default \

ifndef LOCAL_IS_HOST_MODULE
  ifeq (,$(filter true,$(my_clang)))
    ifneq (1,$(words $(filter $(LOCAL_DISABLE_IPA),$(LOCAL_MODULE))))
      my_cflags += -fipa-pta
    endif
  else
    ifneq (1,$(words $(filter $(LOCAL_DISABLE_IPA),$(LOCAL_MODULE))))
      my_cflags += -analyze -analyzer-purge
    endif
  endif
endif

##########
# OpenMP #
##########

LOCAL_DISABLE_OPENMP := \
	libbluetooth_jni \
	bluetooth.mapsapi \
	bluetooth.default \
	libdivsufsort \
	libdivsufsort64 \
	libF77blas \
	libF77blasV8 \
	libjni_latinime \
	libyuv_static \
	mdnsd

ifndef LOCAL_IS_HOST_MODULE
  ifneq (1,$(words $(filter $(LOCAL_DISABLE_OPENMP),$(LOCAL_MODULE))))
    my_cflags += -lgomp -lgcc -fopenmp
    my_ldflags += -fopenmp
  endif
endif

###################
# Strict Aliasing #
###################

LOCAL_DISABLE_STRICT := \
	libbluetooth_jni \
	bluetooth.mapsapi \
	bluetooth.default \
	mdnsd

STRICT_ALIASING_FLAGS := \
	-fstrict-aliasing \
	-Werror=strict-aliasing

STRICT_GCC_LEVEL := \
	-Wstrict-aliasing=3

STRICT_CLANG_LEVEL := \
	-Wstrict-aliasing=2

# Remove the no-strict-aliasing flags
my_cflags := $(filter-out -fno-strict-aliasing,$(my_cflags))
ifneq (1,$(words $(filter $(LOCAL_DISABLE_STRICT),$(LOCAL_MODULE))))
  ifeq (,$(filter true,$(my_clang)))
    my_cflags += $(STRICT_ALIASING_FLAGS) $(STRICT_GCC_LEVEL)
  else
    my_cflags += $(STRICT_ALIASING_FLAGS) $(STRICT_CLANG_LEVEL)
  endif
endif
