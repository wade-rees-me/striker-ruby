# Striker Ruby Simulator

This project simulates blackjack strategies and deck types using a Ruby-based simulator.

## Getting Started

### Prerequisites

- Ruby installed (`ruby` in your path)
- `make`
- Terminal with ANSI color support (optional, for clear screen effects)

### Setup

Make sure your environment is set up correctly and the required Ruby script exists at:

```
./lib/striker_ruby.rb
```

## Building and Running

### Run Simulation

```bash
make run STRATEGY=mimic DECK=single-deck HANDS=100000000 THREADS=1
```

This runs a simulation using the specified strategy and deck.

### Run All Combinations

```bash
make run-all
```

This will run all combinations of strategies and decks.

### Run by Strategy

```bash
make run-mimic
make run-linear
make run-polynomial
make run-neural
make run-basic
make run-high-low
make run-wong
```

Each of these runs the given strategy against all decks.

### Run by Strategy and Deck

```bash
make run-mimic-single-deck
make run-neural-double-deck
make run-high-low-six-shoe
```

### Deck Aliases

- `r1` — Run all strategies on `single-deck`
- `r2` — Run all strategies on `double-deck`
- `r6` — Run all strategies on `six-shoe`

### Strategy Aliases

Run a strategy across all decks:

```bash
make rm     # mimic
make rl     # linear
make rp     # polynomial
make rn     # neural
make rb     # basic
make rh     # high-low
make rw     # wong
```

Run a specific strategy/deck:

```bash
make rm1    # mimic on single-deck
make rn2    # neural on double-deck
make rw6    # wong on six-shoe
```

## Output

Simulation logs are stored in:

```
~/Striker/Simulations/YYYY/MM/DD/
```

Each log is timestamped to avoid overwrites and for historical record keeping.

## Customization

Override these defaults via command-line or environment:

- `HANDS` – Number of hands (default: 100,000,000)
- `THREADS` – Thread count (default: 1)
- `STRATEGY` – Strategy to use
- `DECK` – Deck type

## License

MIT or your license here.
