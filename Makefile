LFLAGS = -lrt -lpthread
#for MacOSX: LFLAGS = -lpthread
INCLUDES := -I./include -I./lexer
CFLAGS := -O3 -march=native -pipe -pthread -UDEBUG -Wall $(INCLUDES)
ifneq ($(strip $(DEBUG)),)
	CFLAGS += -D__DEBUG -g
endif
#CFLAGS := -O3 -pipe -lpthread -Wall $(INCLUDES)
SRCDIR := lib
SRC := $(wildcard $(SRCDIR)/*.c)
ODIR := obj
BINDIR := bin

FOUT := lexer/flex.yy.c
FOBJ := $(ODIR)/flex.yy.o
OBJ := $(patsubst $(SRCDIR)/%.c, $(ODIR)/%.o, $(SRC))

FLEX := lexer/calc.l
GENERATED_FILES = include/config.h include/rewrite_rules.h include/reduction_tree.h include/grammar_tokens.h include/grammar_semantics.h lib/grammar_semantics.c include/grammar.h lib/grammar.c include/matrix.h include/equivalence_matrix.h

all: $(FOBJ) $(OBJ)
	[ -d $(BINDIR) ] || mkdir $(BINDIR)
	$(CC) $(LFLAGS) $(OBJ) $(FOBJ) -o $(BINDIR)/calc

$(FOBJ): $(FOUT)
	[ -d $(ODIR) ] || mkdir $(ODIR)
	$(CC) -c $< -o $@ $(CFLAGS)

$(FOUT): $(FLEX)
	flex -Pyy --header-file=lexer/flex.yy.h -o $@ $<

$(FLEX): $(FLEX).m4
	m4 $< > $@

$(ODIR)/%.o: $(SRCDIR)/%.c
	[ -d $(ODIR) ] || mkdir $(ODIR)
	$(CC) -c $< -o $@ $(CFLAGS)

clean:
	@rm -f $(FLEX)
	@rm -f $(FOUT)
	@rm -f $(patsubst %.c, %.h, $(FOUT))
	@rm -f $(ODIR)/*.o
	@rm -f $(BINDIR)/expr_parser

clean-gen:
	@rm $(GENERATED_FILES)
