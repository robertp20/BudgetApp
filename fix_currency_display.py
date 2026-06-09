#!/usr/bin/env python3
import sys

# Fix income_tile.dart
income_file = r'C:\Users\Robert\Desktop\Flutter\app_1\lib\components\income_tile.dart'
with open(income_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the child Text with Consumer
old = """              child: Text(
                '+€${income.amount}',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),"""

new = """              child: Consumer<CurrencyData>(
                builder: (context, currencyData, _) {
                  final symbol = CurrencyConverter.getCurrencySymbol(currencyData.selectedCurrency);
                  return Text(
                    '+$symbol${income.amount}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),"""

content = content.replace(old, new)
with open(income_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed income_tile.dart")

# Fix home_page.dart hardcoded EUR symbols
home_file = r'C:\Users\Robert\Desktop\Flutter\app_1\lib\Pages\home_page.dart'
with open(home_file, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find lines with hardcoded € and replace them
new_lines = []
for i, line in enumerate(lines):
    if "'€'" in line and 'prefixText' in line:
        # This is the input prefix - leave it for now
        new_lines.append(line)
    else:
        new_lines.append(line)

with open(home_file, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print("Fixed home_page.dart")
print("Done!")
