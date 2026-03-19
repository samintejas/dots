#!/bin/bash
# Single pango-markup string — today highlighted in pink accent

python3 - <<'EOF'
import calendar, datetime

today = datetime.date.today()
cal   = calendar.monthcalendar(today.year, today.month)

lines = []
lines.append('<span foreground="#383838">Mo Tu We Th Fr Sa Su</span>')

for week in cal:
    row = []
    for day in week:
        if day == 0:
            row.append('<span foreground="#222222">  </span>')
        elif day == today.day:
            row.append(f'<span foreground="#ef9cd8">{day:2d}</span>')
        else:
            row.append(f'<span foreground="#484848">{day:2d}</span>')
    lines.append(' '.join(row))

print('\n'.join(lines))
EOF
