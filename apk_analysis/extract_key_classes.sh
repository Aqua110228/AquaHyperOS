#!/bin/sh
# 提取关键类名
DIR="系统界面_17.03.260226.r"
echo "=== QSTile 相关类 ===" > key_classes.txt
for f in $DIR/classes*.dex; do strings "$f"; done | grep "Lcom/android/systemui.*qs.*QSTile" | grep -v "^[a-z]" | sort -u >> key_classes.txt

echo -e "\n=== StatusBar 相关类 ===" >> key_classes.txt
for f in $DIR/classes*.dex; do strings "$f"; done | grep "Lcom/android/systemui.*statusbar.*View" | grep -v "^[a-z]" | sort -u | head -30 >> key_classes.txt

echo -e "\n=== Blur 相关类 ===" >> key_classes.txt
for f in $DIR/classes*.dex; do strings "$f"; done | grep -i "Lcom/android/systemui.*blur" | sort -u >> key_classes.txt

echo -e "\n=== Udfps/Fingerprint 相关类 ===" >> key_classes.txt
for f in $DIR/classes*.dex; do strings "$f"; done | grep -E "Lcom/android/systemui.*(udfps|biometric|fingerprint)" -i | grep "View\|Controller" | sort -u | head -30 >> key_classes.txt

echo -e "\n=== MediaControl 相关类 ===" >> key_classes.txt
for f in $DIR/classes*.dex; do strings "$f"; done | grep "Lcom/android/systemui.*media.*Control" | sort -u | head -20 >> key_classes.txt

echo "提取完成"
