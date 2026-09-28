# Beef & Basil Homebrew tap

The Beef & Basil print agent for the shop's Mac, Apple silicon or Intel.

```sh
brew install bangkeut-technology/tap/bnb-print-agent
bnb-print-agent enrol                               # paste the setup code from Printers in the console
sudo pmset -a sleep 0 disksleep 0 autorestart 1     # a Mac that sleeps prints nothing
brew services start bnb-print-agent
```

It does not update itself: `brew upgrade bnb-print-agent && brew services restart bnb-print-agent`.

Everything here is written by CD in `bangkeut-technology/beef-and-basil`
(`packaging/homebrew/`) each time it builds a new agent. Change it there, not here.
