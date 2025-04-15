# Ruby interpreter
RUBY := ruby

# Strategies and decks
STRATEGIES := mimic linear polynomial neural basic high-low wong
DECKS := single-deck double-deck six-shoe

# Script and output
TARGET := ./lib/striker_ruby.rb
STRIKER := $(HOME)/Striker
HANDS ?= 100000000
THREADS ?= 1
STRATEGY ?= mimic
DECK ?= single-deck

# Logging
DATE := $(shell date +%Y/%m/%d)
TIME := $(shell date +%H%M%S)
LOG_DIR := $(STRIKER)/Simulations/$(DATE)
LOG := $(LOG_DIR)/$(notdir $(TARGET))-$(TIME).log

# Default
.DEFAULT_GOAL := help

# Help info
help:
	@echo "Striker Ruby Simulation Makefile"
	@echo ""
	@echo "Commands:"
	@echo "  run                - Run with STRATEGY and DECK (via vars)"
	@echo "  run-all            - Run all combinations"
	@echo "  run-<strategy>     - Run all decks for a strategy"
	@echo "  run-<strategy>-<deck> - Run specific combination"
	@echo ""
	@echo "Aliases:"
	@echo "  r1, r2, r6         - All strategies on single/double/six-shoe"
	@echo "  rm, rl, rp, rn, rb, rh, rw       - Strategy on all decks"
	@echo "  rm1, rm2, rm6 ...                - Strategy on single/double/six-shoe"
	@echo ""
	@echo "Variables:"
	@echo "  HANDS=<n>          - Number of hands (default: 100000000)"
	@echo "  THREADS=<n>        - Number of threads (default: 1)"
	@echo "  STRATEGY=<s>       - Strategy name"
	@echo "  DECK=<s>           - Deck type"

# Base run command
run:
	@mkdir -p $(LOG_DIR)
	clear
	@echo "Running: $(STRATEGY) / $(DECK) with $(HANDS) hands, $(THREADS) threads"
	$(RUBY) $(TARGET) --$(STRATEGY) --$(DECK) --number-of-hands $(HANDS) | tee $(LOG)

# run-<strategy>-<deck>
define run_template
run-$(1)-$(2):
	@mkdir -p $(LOG_DIR)
	clear
	@echo "Running: $(1) / $(2)"
	$(RUBY) $(TARGET) --$(1) --$(2) --number-of-hands $(HANDS) | tee $(LOG)
endef

$(foreach s,$(STRATEGIES), \
  $(foreach d,$(DECKS), \
    $(eval $(call run_template,$s,$d)) \
  ) \
)

# run-<strategy>
define group_template
run-$(1):
	$(foreach d,$(DECKS), \
		$(MAKE) run-$(1)-$(d);)
endef

$(foreach s,$(STRATEGIES), \
  $(eval $(call group_template,$s)) \
)

# Run all
run-all:
	$(foreach s,$(STRATEGIES), \
		$(MAKE) run-$(s);)

# Deck group aliases
r1:
	$(foreach s,$(STRATEGIES), \
		$(MAKE) run-$(s)-single-deck;)

r2:
	$(foreach s,$(STRATEGIES), \
		$(MAKE) run-$(s)-double-deck;)

r6:
	$(foreach s,$(STRATEGIES), \
		$(MAKE) run-$(s)-six-shoe;)

# Full alias matrix
rm: run-mimic
rm1: run-mimic-single-deck
rm2: run-mimic-double-deck
rm6: run-mimic-six-shoe

rl: run-linear
rl1: run-linear-single-deck
rl2: run-linear-double-deck
rl6: run-linear-six-shoe

rp: run-polynomial
rp1: run-polynomial-single-deck
rp2: run-polynomial-double-deck
rp6: run-polynomial-six-shoe

rn: run-neural
rn1: run-neural-single-deck
rn2: run-neural-double-deck
rn6: run-neural-six-shoe

rb: run-basic
rb1: run-basic-single-deck
rb2: run-basic-double-deck
rb6: run-basic-six-shoe

rh: run-high-low
rh1: run-high-low-single-deck
rh2: run-high-low-double-deck
rh6: run-high-low-six-shoe

rw: run-wong
rw1: run-wong-single-deck
rw2: run-wong-double-deck
rw6: run-wong-six-shoe

