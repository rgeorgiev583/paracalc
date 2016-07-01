NAME := paracalc

LEXDIR := lexer
PARDIR := parser
INCDIR := include
SRCDIR := src
GENDIR := gen
OBJDIR := obj
BINDIR := bin

INCLUDE := -I./$(INCDIR) -I./$(LEXDIR)
CFLAGS := -O3 -pipe -UDEBUG -Wall $(INCLUDE)
ifneq ($(strip $(DEBUG)),)
	CFLAGS += -D__DEBUG -g
endif
LDFLAGS := -lrt -lpthread

GENINC := $(INCDIR)/config.h $(INCDIR)/equivalence_matrix.h $(INCDIR)/grammar.h $(INCDIR)/grammar_semantics.h $(INCDIR)/grammar_tokens.h $(INCDIR)/matrix.h $(INCDIR)/reduction_tree.h $(INCDIR)/rewrite_rules.h
GENSRC := $(SRCDIR)/grammar.c $(SRCDIR)/grammar_semantics.c
GENOBJ := $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(GENSRC))
FLEX := $(LEXDIR)/$(NAME).l
FOUT := $(LEXDIR)/flex.yy.c
FOBJ := $(patsubst $(LEXDIR)/%.c, $(OBJDIR)/%.o, $(FOUT))
SRC := $(wildcard $(SRCDIR)/*.c)
OBJ := $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SRC))

.PHONY: all gen clean clean-gen wipe

all: gen $(GENSRC) $(FOBJ) $(GENOBJ) $(OBJ)
	[ -d $(BINDIR) ] || mkdir $(BINDIR)
	$(CC) $(LDFLAGS) $(FOBJ) $(GENOBJ) $(OBJ) -o $(BINDIR)/$(NAME)

gen: $(GENDIR)/parsergen
	$(GENDIR)/parsergen -i $(PARDIR)/$(NAME).g --out_header $(INCDIR)/ --out_core $(SRCDIR)/

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
	@rm -f $(GENSRC)
	@rm -f $(GENINC)

wipe: clean clean-gen
