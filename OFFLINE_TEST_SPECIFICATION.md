# Flutter Budget App - Offline Functionality Test Specification

## Document Overview
This document provides a comprehensive test plan for validating the offline functionality of the Flutter budget app with multi-currency support. The app integrates with exchangerate-api.com and caches rates locally using Hive.

---

## 1. INITIAL ONLINE SETUP - Test Scenarios

### Test 1.1: First Run Online - Exchange Rate Fetching
**Objective**: Verify that on first app launch with network connectivity, the app successfully fetches exchange rates from the API.

**Prerequisites**:
- Fresh app installation (or Hive cache cleared)
- Device/emulator has active internet connection
- Device is not in flight mode
- API server is reachable

**Test Steps**:
1. Launch the app for the first time
2. Wait 3-5 seconds for app initialization
3. Navigate to ProfilePage
4. Observe the Currency Settings section

**Expected Behavior**:
- App initializes without errors
- ProfilePage loads successfully
- Currency Settings section displays:
  - Dropdown selector with default value: "EUR (€)"
  - Exchange rates list showing:
    - "1 EUR = X.XX BAM"
    - "1 EUR = X.XX USD"
    - "1 EUR = X.XX GBP"
  - "Last updated: YYYY-MM-DD HH:MM:SS" timestamp

**Success Criteria**:
✓ All three currency rates display with numerical values  
✓ Timestamp matches current date/time (within ±5 seconds)  
✓ No error messages or exceptions in console  
✓ Rates are cached to Hive automatically  

**Failure Scenarios & Resolution**:
| Issue | Root Cause | Resolution |
|-------|-----------|-----------|
| Rates show as 0.00 or N/A | API parsing error | Check JSON structure from API |
| Only some rates display | Partial API response | Verify target currencies in ExchangeRateService |
| Timestamp is very old | Cached data not replaced | Check ExchangeRate.fromMap() deserialization |
| Network timeout (>10s) | API slow/unreachable | Use 10s timeout as designed |

**Code Issue Identified**:
⚠️ **ISSUE**: In `currency_data.dart` line 6, `_selectedCurrency` defaults to 'EUR' during initialization, but there's a race condition:
- `prepareData()` loads selected currency from Hive: `_selectedCurrency = _db.loadSelectedCurrency()`
- If Hive hasn't been initialized yet, this could fail silently
- The `_db.loadSelectedCurrency()` in `hive_database.dart` line 126 uses **SharedPreferences** (not Hive!), which is an inconsistency
- **RECOMMENDATION**: Use consistent storage - either Hive or SharedPreferences for both selected currency and exchange rates

---

### Test 1.2: Default Currency is EUR
**Objective**: Verify that EUR is set as the default currency on first launch.

**Prerequisites**:
- Fresh app installation
- Online mode

**Test Steps**:
1. Launch app
2. Navigate to ProfilePage
3. Check Currency dropdown value
4. Verify no transactions have been created yet

**Expected Behavior**:
- Dropdown shows "EUR (€)" as selected
- All amounts in the app are displayed in EUR

**Success Criteria**:
✓ Currency selector defaults to EUR  
✓ Income and expense display uses EUR symbol (€)  

---

### Test 1.3: Exchange Rates Cache to Hive
**Objective**: Verify that fetched rates are persisted to Hive for offline use.

**Prerequisites**:
- Online mode
- Exchange rates successfully fetched

**Test Steps**:
1. After first run, use Flutter debugger or Hive inspection tools
2. Open Hive database 'expense_data'
3. Check for 'EXCHANGE_RATES' key
4. Inspect the cached value structure

**Expected Behavior**:
- Hive box contains 'EXCHANGE_RATES' key
- Value is a Map with structure:
  ```
  {
    'baseCurrency': 'EUR',
    'rates': {'BAM': 1.96, 'USD': 1.05, 'GBP': 0.87},
    'timestamp': '2024-XX-XXTXX:XX:XX.XXXXXX'
  }
  ```

**Success Criteria**:
✓ EXCHANGE_RATES key exists in Hive  
✓ Data structure matches ExchangeRate.toMap() format  
✓ Timestamp is ISO8601 format  

**Code Issue Identified**:
⚠️ **ISSUE**: In `hive_database.dart` lines 119-128, there's an inconsistency:
- `saveSelectedCurrency()` uses **SharedPreferences** (line 120)
- `loadSelectedCurrency()` tries to load from **Hive box** (line 126)
- **BUG**: Saved to SharedPreferences but loaded from Hive!
- **IMPACT**: Currency selection will never persist across app restarts in offline mode
- **FIX NEEDED**: Choose one storage mechanism. Recommend using Hive for consistency with exchange rates.

---

## 2. OFFLINE SCENARIO - Test Procedures

### Test 2.1: App Loads Without Network
**Objective**: Verify the app starts and functions without network connectivity using cached data.

**Prerequisites**:
- Exchange rates cached from Test 1.1
- Device has internet turned off or flight mode enabled

**Test Steps**:
1. Ensure exchange rates are cached from previous online session
2. Enable flight mode or disconnect network adapter
3. Force close the app completely
4. Restart the app
5. Wait for app initialization (should be <2 seconds without network)
6. Check for any error dialogs or warnings

**Expected Behavior**:
- App launches successfully
- No network connectivity error shown
- ProfilePage loads
- Currency Settings section displays cached rates
- Last updated timestamp shows previous session's time

**Success Criteria**:
✓ No crash on startup  
✓ No connectivity error messages  
✓ Cached rates displayed within 2 seconds  
✓ No timeout errors from API calls  

**Failure Scenarios**:
| Symptom | Likely Cause | Mitigation |
|---------|-------------|-----------|
| App hangs on splash screen | API call blocking main thread | Check if ExchangeRateService call is backgrounded |
| Exchange rates missing | Cache expired or corrupted | Verify cache isn't being deleted |
| Generic "No connection" error | Poor error handling | App should gracefully use cache |

---

### Test 2.2: Cached Rates Display in ProfilePage
**Objective**: Verify cached exchange rates appear correctly in the UI when offline.

**Prerequisites**:
- App running offline with cached rates
- From Test 2.1 completion

**Test Steps**:
1. From offline app state
2. Navigate to ProfilePage if not already there
3. Scroll to "Currency Settings" section
4. Inspect the Exchange Rates display
5. Manually verify exchange rates are realistic:
   - EUR = 1.0 (base)
   - BAM ≈ 1.96 (realistic for Bosnian Mark)
   - USD ≈ 1.05 (realistic for US Dollar)
   - GBP ≈ 0.85-0.88 (realistic for British Pound)

**Expected Behavior**:
- All rates from cache display in UI
- Format matches: "1 EUR = X.XX CURRENCY"
- Rates are within realistic ranges

**Success Criteria**:
✓ All three non-base currency rates display  
✓ Rates are properly formatted to 2 decimal places  
✓ Timestamp shows date of last online fetch  

---

### Test 2.3: Currency Selector Works Offline
**Objective**: Verify the currency dropdown is interactive and functional without network.

**Prerequisites**:
- App offline with cached rates
- ProfilePage visible

**Test Steps**:
1. Tap on the currency dropdown
2. Dropdown should open showing options: [BAM (KM), EUR (€), USD ($), GBP (£)]
3. Scroll through all options (if any scrollbar present)
4. Verify each option has proper label with symbol

**Expected Behavior**:
- Dropdown opens smoothly
- All 4 currencies listed with symbols
- Current selection is highlighted (EUR)
- No API calls triggered when opening dropdown

**Success Criteria**:
✓ Dropdown opens without lag  
✓ All 4 currencies visible  
✓ Current selection highlighted  

---

### Test 2.4: Select Different Currency Offline
**Objective**: Verify currency switching works offline without network dependencies.

**Prerequisites**:
- App offline
- Currency dropdown visible
- Currently on EUR

**Test Steps**:
1. Tap currency dropdown
2. Select "USD ($)"
3. Observe dropdown closes and shows "USD ($)"
4. Wait 2 seconds and navigate away from ProfilePage
5. Navigate back to ProfilePage
6. Check if USD is still selected

**Expected Behavior** (Current Implementation):
- Dropdown updates to show "USD ($)"
- Selected currency changes without errors
- No network calls made

**Success Criteria**:
✓ Selection changes immediately in UI  
✓ No error messages  
✓ Dropdown value reflects selection  

---

### Test 2.5: Amounts Display in Selected Currency Offline
**Objective**: Verify that expenses and income convert to selected currency using cached rates.

**Prerequisites**:
- At least 1 expense and 1 income already in the app (from previous online session)
- App offline with cached rates
- Currency switched to USD

**Test Steps**:
1. Navigate to HomePage (expense view)
2. Check expense amounts - should show in USD
3. Navigate to ProfilePage
4. Check "Income Sources" total - should show in USD (but note: code shows hardcoded €)
5. Switch currency to GBP
6. Return to HomePage and ProfilePage
7. Verify amounts update to GBP

**Expected Behavior**:
- Amounts convert using cached exchange rates
- Symbol changes based on selected currency
- All calculations use offline rates

**Success Criteria**:
✓ Amounts update when currency changed  
✓ Conversion uses correct exchange rate  
✓ No API calls made for currency conversion  

**Code Issue Identified**:
⚠️ **ISSUE**: In `profile.dart` lines 74 and 200, hardcoded currency symbols:
```dart
SnackBar(content: Text('Monthly budget saved: €$input')),
SnackBar(content: Text('Income added: €$amount')),
```
- These don't respect selected currency
- In offline mode with USD selected, messages still show EUR
- **RECOMMENDATION**: Use CurrencyConverter.getCurrencySymbol(currencyData.selectedCurrency)

⚠️ **ISSUE**: In `profile.dart` line 287:
```dart
'€${incomeData.getTotalIncome().toStringAsFixed(2)}'
```
- Income total hardcoded to EUR
- Doesn't convert to selected currency
- **RECOMMENDATION**: Apply currency conversion similar to expense display

---

## 3. CURRENCY SWITCHING OFFLINE - Test Procedures

### Test 3.1: Switch Currency While Offline
**Objective**: Verify currency selection persists and conversions work correctly when offline.

**Prerequisites**:
- App offline
- Exchange rates cached
- Current currency: EUR

**Test Steps**:
1. Navigate to ProfilePage
2. Open currency dropdown
3. Select USD
4. Verify dropdown shows "USD ($)"
5. Create or view an expense (should show USD amounts)
6. Switch currency to GBP
7. Verify amounts recalculate

**Expected Behavior**:
- Dropdown updates immediately
- Amounts convert using cached rates
- UI refreshes without network requests

**Success Criteria**:
✓ Dropdown changes to selected currency  
✓ Amounts convert correctly  
✓ No network errors  

---

### Test 3.2: Currency Selection Persists After Restart Offline
**Objective**: Verify selected currency is remembered across app restarts in offline mode.

**Prerequisites**:
- App offline
- Flight mode enabled

**Test Steps**:
1. Select USD from currency dropdown
2. Wait 1 second (allow save to complete)
3. Verify USD is displayed in dropdown
4. Force close the app
5. Reopen the app (still offline)
6. Navigate to ProfilePage
7. Check currency dropdown value

**Expected Behavior**:
- Currency selection persists to next session
- ProfilePage shows USD (USD) on reopening
- No need to re-select currency

**Success Criteria**:
✓ Currency persists after restart  
✓ No data loss  

**CRITICAL BUG IDENTIFIED**:
🔴 **BUG**: The currency selection WON'T persist across restarts!
- Root cause: In `hive_database.dart` lines 119-128:
  ```dart
  Future<void> saveSelectedCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();  // ← Saves to SharedPreferences
    await prefs.setString('SELECTED_CURRENCY', currency);
  }
  
  String loadSelectedCurrency() {
    final box = Hive.box('expense_data');  // ← Loads from Hive!
    return box.get('SELECTED_CURRENCY', defaultValue: 'EUR') as String;
  }
  ```
- **Saved to**: SharedPreferences
- **Loaded from**: Hive box
- **Result**: New currency never persists
- **FIX REQUIRED**: Use consistent storage (recommend Hive for all data)

---

### Test 3.3: No Crashes with Invalid Currency Selection
**Objective**: Verify the app handles edge cases in currency switching gracefully.

**Prerequisites**:
- App offline

**Test Steps**:
1. Monitor console for any errors
2. Rapidly switch currency 5-10 times between options
3. Switch, then immediately restart app (before save completes)
4. Check if app is still stable

**Expected Behavior**:
- No crashes from rapid switching
- App remains responsive
- Worst case: selection defaults to EUR if interrupted

**Success Criteria**:
✓ No null pointer exceptions  
✓ No app crashes  
✓ Graceful degradation  

---

## 4. RECONNECT ONLINE - Test Procedures

### Test 4.1: New Rates Fetch in Background
**Objective**: Verify the app fetches updated rates when network becomes available.

**Prerequisites**:
- App was offline with cached rates
- Flight mode is now disabled or network restored
- App is still running in background

**Test Steps**:
1. App running offline (from Test 2.1)
2. Disable flight mode or restore network connectivity
3. Keep app in foreground on ProfilePage
4. Wait 5-10 seconds
5. Observe Exchange Rates section
6. Check "Last updated" timestamp

**Expected Behavior**:
- App detects network availability
- Background API call initiated
- Exchange Rates section updates with new rates
- "Last updated" timestamp refreshes to current time

**Success Criteria**:
✓ Rates update within 10 seconds of network restore  
✓ New timestamp reflects current time  
✓ No error messages  

**Potential Issue**:
⚠️ **CONCERN**: Current implementation in `main.dart` lines 29-36:
```dart
void _initializeExchangeRates(CurrencyData currencyData) {
  final service = ExchangeRateService();
  service.fetchExchangeRates().then((rate) {
    if (rate != null) {
      currencyData.setExchangeRate(rate);
    }
  });
}
```
- This only runs ONCE at app startup
- If network becomes available later, new rates won't be fetched
- **RECOMMENDATION**: Implement periodic refresh (e.g., every 6 hours) or check on ProfilePage navigation

---

### Test 4.2: UI Updates When New Rates Arrive
**Objective**: Verify the UI refreshes when new exchange rates are fetched online.

**Prerequisites**:
- Test 4.1 completed
- New rates are being fetched from API

**Test Steps**:
1. Note current exchange rates and timestamp from previous offline state
2. Re-enable network
3. Wait for API response (should be <5 seconds)
4. Observe exchange rates values in ProfilePage
5. Compare timestamp

**Expected Behavior**:
- Exchange rates list updates with new values
- Timestamp changes to current time
- UI rebuilds showing new data
- CurrencyData notifyListeners() triggers Provider update

**Success Criteria**:
✓ Rates visibly change (if API values differ)  
✓ Timestamp updates to new time  
✓ UI reflects changes without manual refresh  

---

### Test 4.3: Last Updated Timestamp Refreshes
**Objective**: Verify timestamp updates accurately when new rates are fetched.

**Prerequisites**:
- Test 4.2 progress
- Network online
- New rates fetched

**Test Steps**:
1. Note timestamp before going online
2. Go online and wait for rate fetch (5-10 seconds)
3. Check timestamp after fetch completes
4. Verify timestamp matches "now" ±2 seconds

**Expected Behavior**:
- Timestamp format: "YYYY-MM-DD HH:MM:SS"
- Updates to current date/time
- Reflects when rates were fetched

**Success Criteria**:
✓ Timestamp matches current time (±2 seconds)  
✓ Format is consistent and readable  

---

## 5. EDGE CASES - Test Procedures

### Test 5.1: Cache Empty + App Starts Offline
**Objective**: Verify graceful handling when cache is empty and no network is available.

**Prerequisites**:
- No cached exchange rates (fresh install or cache cleared)
- Network disabled or flight mode on

**Test Steps**:
1. Clear Hive cache (via Hive browser or code)
2. Enable flight mode
3. Launch app fresh
4. Wait for initialization
5. Navigate to ProfilePage

**Expected Behavior**:
- App launches without crashing
- ProfilePage loads
- Currency Settings shows:
  - Dropdown with default EUR (✓ should work)
  - Exchange Rates section shows: "Exchange rates will load when online..."
  - No error message about missing rates
  - No null pointer exceptions

**Success Criteria**:
✓ App doesn't crash with null cache  
✓ Graceful fallback message displayed  
✓ User can still use app with default EUR  

**Code Review**:
✅ **GOOD**: In `profile.dart` lines 489-500, there's a fallback UI:
```dart
else
  Padding(
    child: Text(
      'Exchange rates will load when online...',
      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
    ),
  ),
```
This prevents crashes when `exchangeRate` is null.

---

### Test 5.2: API Timeout (>10 seconds)
**Objective**: Verify app behavior when API is slow to respond.

**Prerequisites**:
- Network connection established but slow
- Can use Charles Proxy or device throttling to simulate latency

**Test Steps**:
1. Throttle network to simulate slow API (use Chrome DevTools or Proxy)
2. Add 15-second artificial delay to API response
3. Launch or refresh app
4. Wait up to 30 seconds

**Expected Behavior**:
- API call times out after 10 seconds (from ExchangeRateService line 14)
- No rates fetch that cycle
- App uses cached rates (if available)
- No error dialog shown to user
- Console shows: "Error fetching exchange rates: ..."

**Success Criteria**:
✓ Timeout occurs at ~10 seconds  
✓ App doesn't hang or freeze  
✓ Cached rates still usable  
✓ No unhandled exceptions  

**Code Analysis**:
✅ **GOOD**: In `exchange_rate_service.dart` line 14:
```dart
.timeout(const Duration(seconds: 10))
```
Timeout is implemented.

✅ **GOOD**: In `exchange_rate_service.dart` line 33-35:
```dart
catch (e) {
  print('Error fetching exchange rates: $e');
}
```
Error is caught and logged (though silent to user).

---

### Test 5.3: API Returns Malformed Data
**Objective**: Verify app handles invalid API responses gracefully.

**Prerequisites**:
- Network online
- Can mock API response (use Mockito or HTTP mocking)

**Test Steps**:
1. Mock exchangerate-api.com to return malformed JSON (e.g., missing 'rates' field)
2. Launch app
3. Observe behavior

**Malformed Response Examples**:
```json
// Example 1: Missing 'rates' key
{ "baseCurrency": "EUR", "timestamp": "2024-..." }

// Example 2: Rates is array instead of object
{ "rates": ["BAM", "USD", "GBP"], "base": "EUR" }

// Example 3: Non-numeric rates
{ "rates": { "BAM": "N/A", "USD": null }, "base": "EUR" }
```

**Expected Behavior**:
- App doesn't crash from malformed data
- Error is caught in try-catch
- Falls back to cached rates
- Console logs error message

**Success Criteria**:
✓ No unhandled exceptions  
✓ App remains stable  
✓ Cached rates still available  

**Code Analysis**:
✅ **GOOD**: In `exchange_rate_service.dart` lines 16-32, data is validated:
```dart
if (response.statusCode == 200) {
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final rates = data['rates'] as Map<String, dynamic>;
  // ...
}
```
If 'rates' is missing, this will throw exception at line 18.

⚠️ **WEAK POINT**: No validation of rate values. If rates are null or strings:
```dart
filteredRates[currency] = (rates[currency] as num).toDouble();  // Could crash here
```
**RECOMMENDATION**: Add null checks and type validation:
```dart
if (rates[currency] is num) {
  filteredRates[currency] = (rates[currency] as num).toDouble();
}
```

---

### Test 5.4: Network Flips Between Online/Offline Multiple Times
**Objective**: Verify app stability when network connectivity changes rapidly.

**Prerequisites**:
- Device in control
- Can toggle network quickly

**Test Steps**:
1. App online, rates fetched
2. Disable network (toggle flight mode)
3. Wait 2 seconds
4. Enable network
5. Wait 3 seconds for rate fetch
6. Disable network again
7. Repeat toggle 5-10 times
8. Check app state

**Expected Behavior**:
- App remains stable throughout toggles
- No crashes from multiple fetch attempts
- Uses latest available rates (online or cached)
- No memory leaks from abandoned API calls

**Success Criteria**:
✓ App doesn't crash  
✓ No memory leaks detected  
✓ Data consistency maintained  

---

### Test 5.5: Very Old Cached Rates (>24 hours)
**Objective**: Verify app handles stale cache appropriately.

**Prerequisites**:
- Modify device date/time or mock Hive timestamp to >24 hours old
- Exchange rates in cache with old timestamp

**Test Steps**:
1. Set cached exchange rate timestamp to 48 hours ago
2. Keep flight mode on (no network)
3. Launch app
4. Check ProfilePage

**Expected Behavior**:
- App displays old rates (better than nothing offline)
- "Last updated" shows old timestamp
- When going online later, new rates fetch and update
- No warning about stale data (though one could be added)

**Success Criteria**:
✓ Old rates display correctly  
✓ No crashes from old timestamps  
✓ New rates fetch when online  

**Code Analysis**:
✅ **EXISTS**: In `exchange_rate.dart` lines 28-32, there's a staleness check:
```dart
bool isStale({int maxAgeHours = 24}) {
  final now = DateTime.now();
  final age = now.difference(timestamp).inHours;
  return age > maxAgeHours;
}
```

⚠️ **UNUSED**: This method is defined but never called in the app!
- **OPPORTUNITY**: Use this in ProfilePage to show warning if rates are stale
- **RECOMMENDATION**: Add UI indicator when rates are >24 hours old

---

## 6. IDENTIFIED ISSUES & FIXES REQUIRED

### Critical Issues (Must Fix)

#### Issue #1: Currency Selection Not Persisting 🔴
**Severity**: CRITICAL  
**Location**: `hive_database.dart` lines 119-128  
**Problem**: Selected currency saved to SharedPreferences but loaded from Hive  
**Impact**: Currency selection resets to EUR on every app restart  
**Fix**:
```dart
// Option 1: Use Hive consistently (RECOMMENDED)
Future<void> saveSelectedCurrency(String currency) async {
  await _myBox.put('SELECTED_CURRENCY', currency);
}

String loadSelectedCurrency() {
  return _myBox.get('SELECTED_CURRENCY', defaultValue: 'EUR') as String;
}

// Option 2: Use SharedPreferences consistently
Future<void> saveSelectedCurrency(String currency) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('SELECTED_CURRENCY', currency);
}

String loadSelectedCurrency() {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('SELECTED_CURRENCY') ?? 'EUR';
}
```

#### Issue #2: Income Display Hardcoded to EUR 🔴
**Severity**: HIGH  
**Location**: `profile.dart` line 287  
**Problem**: Total income shows in EUR regardless of selected currency  
**Impact**: Misleading display when USD/GBP selected; offline amounts incorrect  
**Fix**:
```dart
// Current:
'€${incomeData.getTotalIncome().toStringAsFixed(2)}'

// Fixed:
Consumer<CurrencyData>(
  builder: (context, currencyData, _) {
    double totalIncome = double.parse(incomeData.getTotalIncome());
    double convertedAmount = currencyData.convertAmount(
      totalIncome,
      'EUR',
      currencyData.selectedCurrency,
    );
    String symbol = CurrencyConverter.getCurrencySymbol(currencyData.selectedCurrency);
    return '$symbol${convertedAmount.toStringAsFixed(2)}';
  },
)
```

#### Issue #3: Insufficient Error Handling in Rate Parsing 🔴
**Severity**: MEDIUM  
**Location**: `exchange_rate_service.dart` lines 20-25  
**Problem**: Crashes if API returns non-numeric rates or wrong types  
**Impact**: App fails silently if API malformed; uses null rates  
**Fix**:
```dart
for (var currency in _targetCurrencies) {
  if (rates.containsKey(currency)) {
    final rate = rates[currency];
    if (rate is num && rate > 0) {  // Validate type and value
      filteredRates[currency] = rate.toDouble();
    } else {
      print('Invalid rate for $currency: $rate');
    }
  }
}
```

### High Priority Issues (Should Fix)

#### Issue #4: Background Rate Fetching Only on Startup 🟠
**Severity**: HIGH  
**Location**: `main.dart` lines 29-36  
**Problem**: Exchange rates only fetch once at app launch  
**Impact**: Offline for hours, then going online doesn't fetch new rates  
**Recommendation**: Implement periodic background sync or check on ProfilePage:
```dart
// In profile.dart initState or _ProfilePageState:
Future<void> refreshExchangeRates() async {
  final service = ExchangeRateService();
  final newRates = await service.fetchExchangeRates();
  if (newRates != null) {
    Provider.of<CurrencyData>(context, listen: false).setExchangeRate(newRates);
  }
}

// Or periodic background task (recommended):
Timer? _refreshTimer;

@override
void initState() {
  super.initState();
  // Refresh rates every 6 hours
  _refreshTimer = Timer.periodic(Duration(hours: 6), (_) {
    refreshExchangeRates();
  });
}

@override
void dispose() {
  _refreshTimer?.cancel();
  super.dispose();
}
```

#### Issue #5: No Stale Rate Warning 🟠
**Severity**: MEDIUM  
**Location**: `profile.dart` Currency Settings section  
**Problem**: Rates >24 hours old don't show visual warning  
**Impact**: User may make decisions with outdated exchange rates  
**Fix**:
```dart
if (exchangeRate != null) {
  final isStale = exchangeRate.isStale();
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text('Exchange Rates (Base: EUR)'),
          if (isStale)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Chip(
                label: Text('STALE', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.orange.shade300,
              ),
            ),
        ],
      ),
      // ... rest of rates display
    ],
  );
}
```

#### Issue #6: Hardcoded Currency in Success Messages 🟠
**Severity**: MEDIUM  
**Location**: `profile.dart` lines 74, 200  
**Problem**: Success messages show EUR symbol even when USD/GBP selected  
**Impact**: Confusing UX when using non-EUR currency offline  
**Fix**:
```dart
// Current line 74:
SnackBar(content: Text('Monthly budget saved: €$input')),

// Fixed:
String symbol = CurrencyConverter.getCurrencySymbol(
  Provider.of<CurrencyData>(context, listen: false).selectedCurrency
);
SnackBar(content: Text('Monthly budget saved: $symbol$input')),
```

---

## 7. TESTING CHECKLIST

### Pre-Test Setup
- [ ] Fresh Flutter environment or clean Hive cache
- [ ] exchangerate-api.com is accessible
- [ ] Test device/emulator has network control (flight mode capability)
- [ ] Can inspect Hive database (use Hive Inspector or debugger)
- [ ] Console access to view logs

### Test Execution Order
- [ ] Test 1.1: First run fetches rates
- [ ] Test 1.2: Default currency EUR
- [ ] Test 1.3: Rates cached to Hive
- [ ] Test 2.1: App loads offline
- [ ] Test 2.2: Cached rates display
- [ ] Test 2.3: Currency selector works offline
- [ ] Test 2.4: Select different currency offline
- [ ] Test 2.5: Amounts display in selected currency
- [ ] Test 3.1: Switch currency while offline
- [ ] Test 3.2: Currency selection persists offline
- [ ] Test 3.3: No crashes with rapid switching
- [ ] Test 4.1: New rates fetch when online
- [ ] Test 4.2: UI updates with new rates
- [ ] Test 4.3: Timestamp refreshes
- [ ] Test 5.1: Empty cache + offline startup
- [ ] Test 5.2: API timeout handling
- [ ] Test 5.3: Malformed API response
- [ ] Test 5.4: Network flips stability
- [ ] Test 5.5: Very old cached rates

### Pass/Fail Criteria
- **PASS**: All 20 tests pass + all Critical issues fixed
- **FAIL**: Any Critical issue present or 3+ test failures
- **CONDITIONAL PASS**: High priority issues documented for future sprint

---

## 8. RECOMMENDATIONS FOR IMPROVEMENTS

### Short Term (Sprint 1)
1. **Fix currency persistence** (Issue #1) - 30 minutes
2. **Fix income display currency** (Issue #2) - 20 minutes
3. **Add rate validation** (Issue #3) - 25 minutes
4. **Add stale rate indicator** (Issue #5) - 20 minutes

### Medium Term (Sprint 2-3)
1. **Implement periodic rate refresh** (Issue #4)
2. **Add network connectivity monitoring** - use connectivity_plus package
3. **Add "Refresh" button in ProfilePage** for manual rate update
4. **Implement rate comparison** - show old vs new rates
5. **Add user notification** when rates update automatically

### Long Term
1. **Support for additional currencies** - make list configurable
2. **Local database for rate history** - track rate changes over time
3. **Offline conversion recommendations** - suggest when to convert currency
4. **Watchdog/monitoring** - alert if rates too stale
5. **Rate caching strategy** - implement intelligent cache invalidation

---

## 9. EQUIPMENT & TOOLS NEEDED FOR TESTING

### Required
- Flutter development environment (Flutter SDK 3.10.3+)
- Test device or emulator with network control
- exchangerate-api.com API access
- Hive Inspector or Flutter DevTools

### Optional
- Charles Proxy or equivalent (for network throttling)
- Mockito library (for mocking API responses)
- Dart HTTP mocking (mock_web_server)
- Device with multiple accounts (to test separate cache instances)

---

## 10. SUCCESS CRITERIA SUMMARY

The offline functionality is considered **SUCCESSFUL** when:

✅ **Functional**
- Exchange rates successfully cached and retrieved offline
- Currency selection works offline
- All amounts convert using cached rates
- No network errors when offline

✅ **Persistent**
- Selected currency persists across restarts
- Cached rates remain valid
- No data loss during offline operation

✅ **Robust**
- App handles empty cache gracefully
- API timeouts handled correctly
- Malformed responses don't crash app
- Rapid network changes don't destabilize app

✅ **User Experience**
- ProfilePage shows clear indication of last update time
- Stale rates are clearly marked
- Fallback message when rates unavailable
- No confusing error messages

✅ **Performance**
- App initializes <3 seconds offline
- Currency switching is instant
- Conversions calculate without lag
- No memory leaks from repeated fetch attempts

---

## Document Control
- **Created**: 2024
- **Last Updated**: 2024
- **Version**: 1.0
- **Status**: Ready for Testing
- **Next Review**: After first test cycle
