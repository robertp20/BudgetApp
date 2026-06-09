import re

path = r'C:\Users\Robert\Desktop\Flutter\app_1\lib\Pages\profile.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Find the insertion point - between the income card and the info card
# Look for the pattern after the ElevatedButton for "Add Income"
currency_ui = '''                   ),
                   const SizedBox(height: 20),

                   // Currency Settings Section
                   Consumer<CurrencyData>(
                     builder: (context, currencyData, _) {
                       final exchangeRate = currencyData.exchangeRate;
                       return Card(
                         elevation: 2,
                         child: Padding(
                           padding: const EdgeInsets.all(16.0),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.stretch,
                             children: [
                               const Text(
                                 'Currency Settings',
                                 style: TextStyle(
                                   fontSize: 18,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                               const SizedBox(height: 16),
                               Row(
                                 children: [
                                   const Text(
                                     'Currency:',
                                     style: TextStyle(fontWeight: FontWeight.w500),
                                   ),
                                   const SizedBox(width: 12),
                                   Expanded(
                                     child: DropdownButton<String>(
                                       isExpanded: true,
                                       value: currencyData.selectedCurrency,
                                       items: CurrencyConverter.supportedCurrencies
                                           .map((currency) => DropdownMenuItem(
                                                 value: currency,
                                                 child: Row(
                                                   children: [
                                                     Text(currency),
                                                     const SizedBox(width: 8),
                                                     Text(
                                                       '(${CurrencyConverter.getCurrencySymbol(currency)})',
                                                       style: TextStyle(
                                                         color: Colors.grey.shade600,
                                                         fontSize: 12,
                                                       ),
                                                     ),
                                                   ],
                                                 ),
                                               ))
                                           .toList(),
                                       onChanged: (newCurrency) {
                                         if (newCurrency != null) {
                                           currencyData.setSelectedCurrency(newCurrency);
                                         }
                                       },
                                     ),
                                   ),
                                 ],
                               ),
                               const SizedBox(height: 16),
                               if (exchangeRate != null)
                                 Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       'Exchange Rates (Base: EUR)',
                                       style: TextStyle(
                                         fontSize: 14,
                                         fontWeight: FontWeight.w500,
                                         color: Colors.grey.shade700,
                                       ),
                                     ),
                                     const SizedBox(height: 8),
                                     ...exchangeRate.rates.entries
                                         .map((entry) => Padding(
                                               padding: const EdgeInsets.symmetric(vertical: 4.0),
                                               child: Row(
                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                 children: [
                                                   Text(
                                                     '1 EUR = ${entry.value.toStringAsFixed(2)} ${entry.key}',
                                                     style: const TextStyle(fontSize: 13),
                                                   ),
                                                 ],
                                               ),
                                             ))
                                         .toList(),
                                     const SizedBox(height: 8),
                                     Text(
                                       'Last updated: ${exchangeRate.timestamp.toString().split('.')[0]}',
                                       style: TextStyle(
                                         fontSize: 12,
                                         color: Colors.grey.shade600,
                                         fontStyle: FontStyle.italic,
                                       ),
                                     ),
                                   ],
                                 )
                               else
                                 Padding(
                                   padding: const EdgeInsets.symmetric(vertical: 8.0),
                                   child: Text(
                                     'Exchange rates will load when online...',
                                     style: TextStyle(
                                       fontSize: 13,
                                       color: Colors.grey.shade600,
                                       fontStyle: FontStyle.italic,
                                     ),
                                   ),
                                 ),
                             ],
                           ),
                         ),
                       );
                     },
                   ),
                   const SizedBox(height: 20),

                   // Info Card'''

# Replace pattern: find the closing of Income section and add currency section before Info Card
pattern = r'(                   \),\n                   const SizedBox\(height: 20\),\n\n                   // Info Card)'
replacement = currency_ui + '\n                   Card('

# Try the replacement
if re.search(pattern, content):
    print("Pattern found!")
    new_content = re.sub(pattern, replacement, content)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("File updated!")
else:
    print("Pattern not found. Trying simpler search...")
    # Try a simpler search for just the income card closing
    if re.search(r'// Info Card', content):
        print("Info Card comment found")
        # Find the exact position
        match = re.search(r'const SizedBox\(height: 20\),\n\n                   // Info Card', content)
        if match:
            print(f"Found at position {match.start()}")
            new_content = content[:match.start()] + currency_ui + '\n' + content[match.start():]
            with open(path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print("File updated with simpler pattern!")
