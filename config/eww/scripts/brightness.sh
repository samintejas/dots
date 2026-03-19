#!/bin/bash
cur=$(brightnessctl get 2>/dev/null)
max=$(brightnessctl max 2>/dev/null)
[[ -n "$cur" && -n "$max" && "$max" -gt 0 ]] && echo $(( cur * 100 / max )) || echo 50
