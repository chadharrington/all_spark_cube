PROGRAM = cubedriver
SRCDIRS = .

CC = gcc
CFLAGS = -Wall -Wextra  -O3
LDFLAGS = -lftd2xx

SOURCES = $(foreach d,$(SRCDIRS),$(wildcard $(addprefix $(d)/*,.c)))
HEADERS = $(foreach d,$(SRCDIRS),$(wildcard $(addprefix $(d)/*,.h)))
OBJS    = $(addsuffix .o, $(basename $(SOURCES)))
DEPS    = $(OBJS:.o=.d)

DEPEND      = $(CC) -MM -MP $(CFLAGS) 
DEPEND.d    = $(subst -g ,,$(DEPEND))

all: $(PROGRAM)

%.d:%.c
	@echo -n $(dir $<) > $@
	@$(DEPEND.d) $< >> $@

%.o:%.c
	@$(CC) $(CFLAGS) -c $< -o $@

$(PROGRAM):$(OBJS)
	@$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) -o $@

clean:
	@rm -f $(OBJS) $(PROGRAM) 
