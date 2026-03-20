Find the latest file in ~/tmp/sshots/ by modification time and read/display it.

Use this bash command to find the latest screenshot:
```
find ~/tmp/sshots/ -type f -printf '%T@ %p\n' | sort -rn | head -1 | awk '{print $2}'
```

Then read and display the image file at that path.
