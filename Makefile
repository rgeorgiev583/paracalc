NAME := paracalc

LEXDIR := lexer
PARDIR := parser
INCDIR := include
SRCDIR := lib
GENDIR := gen
OBJDIR := obj
BINDIR := bin

INCLUDE := -I./$(INCDIR) -I./$(LEXDIR)
CFLAGS := -O3 -pipe -UDEBUG -Wall $(INCLUDE)
ifneq ($(strip $(DEBUG)),)
	CFLAGS += -D__DEBUG -g
endif
LDFLAGS := -lrt -lpthread

FLEX := $(LEXDIR)/$(NAME).l
FOUT := $(LEXDIR)/flex.yy.c
FOBJ := $(patsubst $(LEXDIR)/%.c, $(OBJDIR)/%.o, $(FOUT))
SRC := $(wildcard $(SRCDIR)/*.c)
OBJ := $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SRC))

GENERATED_FILES := include/config.h include/rewrite_rules.h include/reduction_tree.h include/grammar_tokens.h include/grammar_semantics.h lib/grammar_semantics.c include/grammar.h lib/grammar.c include/matrix.h include/equivalence_matrix.h

.PHONY: all gen clean clean-gen wipe

all: gen $(FOBJ) $(OBJ)
	[ -d $(BINDIR) ] || mkdir $(BINDIR)
	$(CC) $(LDFLAGS) $(FOBJ) $(OBJ) -o $(BINDIR)/$(NAME)

gen: $(GENDIR)/parsergen
	$(GENDIR)/parsergen -i $(PARDIR)/$(NAME).g --out_header $(INCDIR) --out_core $(SRCDIR)

$(FOBJ): $(FOUT)
	[ -d $(OBJDIR) ] || mkdir $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(FOUT): $(FLEX)
	flex --header-file=lexer/flex.yy.h -o $@ $<

$(FLEX): $(FLEX).m4
	m4 $< > $@

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	[ -d $(OBJDIR) ] || mkdir $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	@rm -f $(BINDIR)/DEBUG
	@rm -f $(BINDIR)/$(NAME)
	@rm -f $(OBJDIR)/*.o
	@rm -f $(FOUT)
	@rm -f $(patsubst %.c, %.h, $(FOUT))
	@rm -f $(FLEX)

clean-gen:
	@rm -f $(GENERATED_FILES)

wipe: clean clean-gen
