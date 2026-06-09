# Flutter Budget App - Offline Testing Procedures & Commands

## Quick Start: How to Run Offline Tests

### Part 0: Environment Setup (One-time)

#### 0.1 Clear Hive Cache for Fresh Start
```bash
# Delete the Hive database file to start fresh
# Windows (from project root):
rmdir /s /q build

# Or manually:
# 1. Connect debugger
# 2. Use Flutter DevTools -> Local Hive Inspector
# 3. Delete 'expense_data' box
```

#### 0.2 Ensure Network Access First
```bash
# Test API endpoint:
curl "https://api.exchangerate-api.com/v4/latest/EUR"

# Expected response (within 5 seconds):
{
  "base": "EUR",
  "date": "2024-XX-XX",
  "rates": {
    "BAM": 1.95-1.97,
    "USD": 1.04-1.08,
    "GBP": 0.84-0.88,
    ...
  }
}
```

---

## PHASE 1: Online Setup Tests

### Test 1.1 Execution: Fresh Install - Fetch Rates Online

**Duration**: 5-10 minutes  
**Network**: REQUIRED  
**Cache**: EMPTY  

#### Pre-Test Checklist
```
□ App never run before (or Hive cleared)
□ Network/WiFi connected
□ Flight mode OFF
□ Device date/time correct
□ API endpoint accessible (curl test from 0.2)
□ Device clock synchronized
```

#### Step-by-Step Procedure
```
1. OPEN NEW TERMINAL & START FLUTTER APP:
   $ flutter run -v
   
   OBSERVE:
   - "Launching lib/main.dart on [Device]"
   - App starts and shows splash screen
   - Wait for HomePage or ProfilePage to load
   
2. NAVIGATE TO PROFILE PAGE:
   - Tap navigation menu (if present) or click "Settings" tab
   - If ProfilePage doesn't auto-show, tap Profile icon
   
3. SCROLL TO CURRENCY SETTINGS SECTION:
   - Look for "Currency Settings" card
   - Wait 2-3 seconds for exchange rates to appear
   
4. VERIFY EXCHANGE RATES DISPLAY:
   Check these exact elements appear:
   
   ✓ Section title: "Currency Settings"
   ✓ Dropdown showing: "EUR (€)" selected
   ✓ Exchange rates lines:
     "1 EUR = 1.95-1.97 BAM"     (typical range)
     "1 EUR = 1.04-1.08 USD"     (typical range)
     "1 EUR = 0.84-0.88 GBP"     (typical range)
   ✓ Timestamp: "Last updated: YYYY-MM-DD HH:MM:SS"
     (should be within ±5 seconds of current time)
   ✓ No error messages
   ✓ No "0.00" values
   ✓ No null/undefined
   
5. CHECK CONSOLE FOR ERRORS:
   $ (In terminal where flutter run is running)
   
   Should NOT see:
   ✗ "Error fetching exchange rates"
   ✗ "Null reference"
   ✗ "Exception"
   ✗ Network errors
   
   May see:
   ✓ "Packages loaded" message
   ✓ Normal widget build logs
```

#### Verification Points
| Element | Expected | Status |
|---------|----------|--------|
| Rates displayed | Yes | [ ] |
| Correct format | "1 EUR = X.XX XXX" | [ ] |
| Timestamp valid | Current time ±5s | [ ] |
| No errors | No crash/exception | [ ] |
| Default EUR | Dropdown shows EUR | [ ] |
| 3 currencies | BAM, USD, GBP all shown | [ ] |

#### If Test Fails
| Symptom | Debug Steps |
|---------|------------|
| Rates show "0.00" | Check `exchange_rate_service.dart` JSON parsing |
| Only 1-2 rates show | Check if API missing currencies |
| Very old timestamp | Verify device clock correct |
| Timeout error | Check network connectivity |
| No rates displayed | Verify API response with curl (step 0.2) |
| Timestamp shows "NaN" | Check DateTime.parse() in ExchangeRate.fromMap() |

#### Expected Console Output
```
I/flutter ( 1234): Building app...
I/flutter ( 1234): Initializing Hive...
I/flutter ( 1234): Exchange rates fetched successfully
I/flutter ( 1234): Rates cached to Hive
I/flutter ( 1234): ProfilePage initialized
```

---

### Test 1.2 Execution: Verify Hive Cache

**Duration**: 3-5 minutes  
**Network**: REQUIRED (data already fetched)  
**Cache**: JUST POPULATED (from Test 1.1)  

#### Using Flutter DevTools (Recommended)

```
1. OPEN DEVTOOLS IN BROWSER:
   - In terminal where app runs, find link: "DevTools at http://127.0.0.1:PORT"
   - Open in browser
   
2. NAVIGATE TO "Hive" TAB:
   - Click "Hive" in left sidebar
   - (If not visible, click "..." → "Open Hive Inspector")
   
3. SELECT "expense_data" BOX:
   - See list of box names
   - Click "expense_data"
   
4. SEARCH FOR "EXCHANGE_RATES" KEY:
   - In key list, find entry: "EXCHANGE_RATES"
   - Click on it
   
5. VERIFY STRUCTURE:
   Should see JSON structure:
   {
     "baseCurrency": "EUR",
     "rates": {
       "BAM": 1.96,
       "USD": 1.05,
       "GBP": 0.87
     },
     "timestamp": "2024-XX-XXTXX:XX:XX.XXXXXX"
   }
   
6. VALIDATE VALUES:
   □ baseCurrency = "EUR"
   □ rates.BAM ≈ 1.95-1.97
   □ rates.USD ≈ 1.04-1.08
   □ rates.GBP ≈ 0.84-0.88
   □ timestamp is ISO8601 format
   □ timestamp is recent (within 1 minute)
```

#### Using ADB (Android Emulator)
```
1. CONNECT TO DEVICE:
   $ adb shell
   
2. ACCESS HIVE DATABASE:
   $ cd /data/user/0/com.example.app_1/app_flutter/
   
3. VIEW DATABASE FILES:
   $ ls -la
   (Should see .hive files)
   
4. Extract for inspection:
   $ adb pull /data/user/0/com.example.app_1/app_flutter/expense_data.hive
```

#### Expected Hive State After Test 1.1
```
expense_data box contains:
  ├─ EXCHANGE_RATES (Map with rates)
  ├─ ALL_EXPENSE (List of expenses, may be empty)
  ├─ ALL_INCOMES (List of incomes, may be empty)
  └─ MONTHLY_INCOME (String, default "0.0")
```

---

## PHASE 2: Offline Mode Tests

### Pre-Offline Setup (Common for Tests 2.1-2.5)

```
BEFORE STARTING PHASE 2 TESTS:

1. Verify rates are cached (Test 1.1 & 1.2 passed):
   □ exchange rates showing in ProfilePage
   □ EXCHANGE_RATES in Hive
   
2. Enable Flight Mode:
   Windows/Mac: Not applicable (use network disconnect)
   Android: Settings → Network & Internet → Airplane mode ON
   iOS: Control Center → Airplane mode ON
   Emulator: Can disable network via emulator settings
   
3. Confirm No Network:
   $ ping 8.8.8.8
   (Should timeout/fail)
   
4. Keep App Running:
   Do NOT restart app yet (test offline app state first)
```

---

### Test 2.1 Execution: App Loads Offline Without Crashing

**Duration**: 5 minutes  
**Network**: OFFLINE  
**Cache**: POPULATED (from Test 1.1)  
**App State**: RUNNING (from online session)  

#### Procedure
```
STEP 1: VERIFY CURRENT STATE (Before going offline)
- App still showing ProfilePage with rates
- Rates display: 1 EUR = X.XX XXX format
- Timestamp shows recent time
- Command: None (just observe UI)

STEP 2: ENABLE FLIGHT MODE
Android:
  Settings → Network & internet → Airplane mode
  Toggle ON
  Verify WiFi symbol disappears from status bar

iOS:
  Control Center → Airplane mode (airplane icon)
  Toggle ON
  Verify Bluetooth/WiFi disabled

Desktop Emulator:
  Emulator settings → Advanced → Network speed
  Set to "None"

STEP 3: WAIT 2 SECONDS
- Gives network stack time to drop connections
- Allows any pending API calls to timeout

STEP 4: VERIFY APP STATE (WITHOUT restarting)
While offline, on same session:
  ✓ App still responsive to taps
  ✓ No error popup/dialog
  ✓ ProfilePage still visible
  ✓ Rates still display
  ✓ No "Network Error" message
  ✓ CPU/memory normal (no crash)

STEP 5: FORCE CLOSE APP
Android:
  $ adb shell am force-stop com.example.app_1
iOS:
  Swipe up from bottom → swipe app up
Desktop:
  Terminal: flutter run → Ctrl+C
  Close emulator window

STEP 6: RESTART APP WHILE OFFLINE
Flight mode still ON

$ flutter run -v

OBSERVE STARTUP:
- App initializes (expect faster than online)
- Splash screen appears
- HomePage/ProfilePage loads
- Should complete <3 seconds

VERIFY NO ERRORS:
✗ No "Connection refused"
✗ No "Network timeout"
✗ No "API unreachable"
✗ No crash/exception
✗ No blank screen
✗ No infinite loading spinner

STEP 7: NAVIGATE TO PROFILEPAGE
- Tap Profile/Settings
- Wait 1 second
- Currency Settings section loads
```

#### Pass Criteria
```
✓ App launches successfully while offline
✓ ProfilePage loads within 3 seconds
✓ No network error messages
✓ No exceptions in console
✓ No crash
✓ Exchange rates section present and populated
```

#### Common Issues & Fixes

| Issue | Cause | Check |
|-------|-------|-------|
| App hangs on splash | API call blocking UI thread | Kill app, check for try-catch |
| Exchange rates missing | Cache not persisted | Verify Test 1.2 success |
| Old timestamp | Cache not updated | Run Test 1.1 again |
| "No network" error | Error message not silenced | Check error handling |

---

### Test 2.2 Execution: Verify Cached Rates Display

**Duration**: 3 minutes  
**Network**: OFFLINE  
**App State**: Restarted offline (from Test 2.1)  

#### Procedure
```
STEP 1: VERIFY PROFILEPAGE VISIBLE
Location: ProfilePage → Scroll to Currency Settings

STEP 2: READ EXCHANGE RATES DISPLAY
Note the exact values showing:
  Rate 1: 1 EUR = ___.__ BAM
  Rate 2: 1 EUR = ___.__ USD
  Rate 3: 1 EUR = ___.__ GBP

STEP 3: VALIDATE REALISTIC RANGES
Compare against known ranges:
  BAM: 1.90-2.00 ✓ or ✗
  USD: 1.00-1.15 ✓ or ✗
  GBP: 0.80-0.95 ✓ or ✗

STEP 4: CHECK TIMESTAMP
Read "Last updated: YYYY-MM-DD HH:MM:SS"
This should be from Test 1.1 session
  Should NOT be current time (since offline)
  Should be date/time from earlier session
```

#### Expected Display Format
```
Currency Settings
─────────────────────
Currency: [EUR (€) ▼]

Exchange Rates (Base: EUR)
1 EUR = 1.96 BAM
1 EUR = 1.05 USD
1 EUR = 0.87 GBP

Last updated: 2024-XX-XX XX:XX:XX
```

#### Pass Criteria
```
✓ All three currency rates visible
✓ Rates formatted: "1 EUR = X.XX CURRENCY"
✓ No "N/A", "0.00", or null values
✓ Timestamp from cached session
✓ Values within realistic ranges
```

---

### Test 2.3 Execution: Currency Selector Works Offline

**Duration**: 3 minutes  
**Network**: OFFLINE  
**App State**: ProfilePage visible  

#### Procedure
```
STEP 1: LOCATE CURRENCY DROPDOWN
Currency Settings section → dropdown showing "EUR (€)"

STEP 2: TAP DROPDOWN TO OPEN
Click on dropdown button next to "EUR (€)"

EXPECTED: Dropdown expands showing options:
  [ ] BAM (KM)
  [ ] EUR (€)
  [ ] USD ($)
  [ ] GBP (£)

STEP 3: VERIFY ALL OPTIONS VISIBLE
  □ All 4 currencies listed
  □ Currency code and symbol both shown
  □ EUR has checkmark/highlight (currently selected)
  □ No "Loading..." spinner
  □ No error messages

STEP 4: CLOSE DROPDOWN
  Click outside dropdown or press Escape

STEP 5: VERIFY NO SIDE EFFECTS
  □ App remains responsive
  □ Rates still display
  □ No network calls triggered (check console)
  □ No lag or freeze
```

#### Pass Criteria
```
✓ Dropdown opens without network request
✓ All 4 currencies visible
✓ No lag when opening
✓ Closes cleanly when tapped outside
✓ EUR highlighted as current selection
```

---

### Test 2.4 Execution: Select Different Currency Offline

**Duration**: 5 minutes  
**Network**: OFFLINE  
**App State**: ProfilePage with dropdown visible  

#### Procedure - Part A: Select USD
```
STEP 1: OPEN DROPDOWN (same as Test 2.3)
Tap currency dropdown

STEP 2: SELECT USD
Click on "USD ($)" option

EXPECTED RESULT:
  ✓ Dropdown closes
  ✓ Dropdown now shows "USD ($)"
  ✓ No error message
  ✓ Exchange Rates section still visible
  ✓ Rates unchanged (still 1 EUR = X.XX)

STEP 3: WAIT 2 SECONDS
Allow any background save to complete

STEP 4: CHECK CONSOLE
$ (observe flutter run terminal)
Should see:
  ✓ "setSelectedCurrency called" or similar
  ✗ No "Error saving currency"
  ✗ No exception
```

#### Procedure - Part B: Switch to GBP
```
STEP 5: OPEN DROPDOWN AGAIN
Tap dropdown again

VERIFY:
  ✓ USD now shows as selected (highlighted)
  ✓ Can tap GBP option

STEP 6: SELECT GBP
Click on "GBP (£)"

EXPECTED:
  ✓ Dropdown shows "GBP (£)"
  ✓ Instant UI update
  ✓ No network calls
```

#### Procedure - Part C: Switch Back to EUR
```
STEP 7: SWITCH BACK TO EUR
Repeat process to select EUR

VERIFY:
  ✓ Cycles through currencies without errors
  ✓ No accumulating issues
  ✓ Each selection is instant
```

#### Pass Criteria
```
✓ Dropdown selection changes immediately
✓ No errors when switching offline
✓ Multiple switches don't cause issues
✓ Console shows no errors
✓ UI responsive throughout
```

---

### Test 2.5 Execution: Amounts Display in Selected Currency Offline

**Duration**: 8 minutes  
**Network**: OFFLINE  
**Precondition**: Must have expenses/income from previous online session  

#### Procedure - Part A: Check Initial EUR Amounts
```
STEP 1: ENSURE YOU HAVE TEST DATA
Create test data while online:
  - Add 1 expense: €100 (food)
  - Add 1 income: €1000 (salary)
  
OR use existing data

STEP 2: NOTE EUR AMOUNTS
On offline app:
  HomePage:
    - Expense showing: "€100" or similar
    - Bar chart labeled in EUR
  
  ProfilePage:
    - Income total showing: "€1000" or similar
```

#### Procedure - Part B: Switch to USD & Verify Conversion
```
STEP 3: SELECT USD FROM DROPDOWN
Profile → Currency dropdown → "USD ($)"
Wait 1 second

STEP 4: CHECK HOMEPAGE EXPENSE DISPLAY
Navigate to HomePage
Look for amount display

EXPECTED CONVERSION:
  If expense is €100 and rate is 1 EUR = 1.05 USD:
    Display should show: "$105.00"
  
  Formula check: 100 * 1.05 = 105 ✓

VERIFY DETAILS:
  ✓ Symbol changed to $ (not €)
  ✓ Amount changed (converted correctly)
  ✓ Format consistent with EUR display
  ✓ Bar chart labeled with USD
  ✓ No "N/A" or null values

STEP 5: CHECK PROFILEPAGE INCOME DISPLAY
Profile → Income Sources section

ISSUE: Current code shows hardcoded €
Expected (current buggy behavior):
  Display: "€1000" (WRONG - shows EUR despite USD selected)

EXPECTED (if fixed):
  Display: "$1050.00" (correctly converted)
```

#### Procedure - Part C: Switch to GBP & Verify
```
STEP 6: SELECT GBP FROM DROPDOWN
Currency dropdown → "GBP (£)"

STEP 7: VERIFY AMOUNTS RECONVERT
Check amounts update with new rate

Example:
  If rate is 1 EUR = 0.87 GBP:
    €100 → £87.00 ✓

VERIFY:
  ✓ Symbol changes to £
  ✓ Amount recalculates using correct rate
  ✓ Historical accuracy (same amount, different currency)
  ✓ All displayed amounts consistent
```

#### Pass Criteria
```
✓ Amounts convert to selected currency
✓ Conversion math is correct (offline, using cached rates)
✓ Symbol updates with currency
✓ Multiple conversions don't break display
⚠️ Income total may show € instead of selected currency (known issue)
```

#### Expected Calculations
```
Test Data: €100 expense, €1000 income
Rates: 1 EUR = 1.96 BAM, 1.05 USD, 0.87 GBP

EUR (default):
  Expense: €100.00
  Income: €1000.00

USD conversion:
  Expense: $105.00    (100 * 1.05)
  Income: $1050.00    (1000 * 1.05)

GBP conversion:
  Expense: £87.00     (100 * 0.87)
  Income: £870.00     (1000 * 0.87)

BAM conversion:
  Expense: KM196.00   (100 * 1.96)
  Income: KM1960.00   (1000 * 1.96)
```

---

## PHASE 3: Offline Persistence Tests

### Test 3.1 Execution: Currency Selection Persists After Restart

**Duration**: 8 minutes  
**Network**: OFFLINE (flight mode ON)  
**Critical**: This test reveals the persist bug!  

#### Procedure
```
STEP 1: SELECT USD CURRENCY
ProfilePage → Currency dropdown → "USD ($)"
Wait 2 seconds (ensure save completes)

STEP 2: VERIFY DROPDOWN SHOWS USD
Dropdown should display: "USD ($)"
Confirm visually

STEP 3: FORCE CLOSE APP
Option A - Clean close:
  Press Ctrl+C in Flutter terminal
  $ flutter run (to stop it)
  
Option B - Hard kill:
  $ adb shell am force-stop com.example.app_1
  
Option C - Manual:
  Close emulator window

STEP 4: RESTART APP (STILL OFFLINE)
Flight mode still ON

$ flutter run -v

STEP 5: NAVIGATE TO PROFILEPAGE
Allow app to fully load
Tap Profile/Settings

STEP 6: CHECK CURRENCY DROPDOWN
Look at dropdown value

EXPECTED (If working correctly):
  Dropdown shows: "USD ($)"
  ✓ Selection persisted across restart

ACTUAL (Current bug):
  Dropdown shows: "EUR (€)"
  ✗ Selection reverted to default
  
THIS IS BUG #1 from specification
```

#### Why Bug Occurs
```
Current Code Flow:

Save Currency:
  hive_database.saveSelectedCurrency("USD")
  → Uses SharedPreferences
  → prefs.setString('SELECTED_CURRENCY', 'USD')

Load Currency:
  hive_database.loadSelectedCurrency()
  → Uses Hive
  → box.get('SELECTED_CURRENCY', defaultValue: 'EUR')
  → Returns 'EUR' (never saved to Hive!)

Result: Save to A, Load from B → Currency lost!
```

#### Pass Criteria
```
CURRENT STATUS (with bug):
✗ FAIL: Currency reverts to EUR

AFTER FIX:
✓ PASS: Currency remains USD after restart
```

---

### Test 3.2 Execution: Data Consistency During Network Toggles

**Duration**: 8 minutes  
**Network**: TOGGLES between online/offline  

#### Procedure
```
STEP 1: OFFLINE BASELINE
Start: Offline with USD selected

STEP 2: GO ONLINE
Disable flight mode
Wait 3 seconds for network stabilization

STEP 3: OBSERVE RATES UPDATE
ProfilePage should show updating rates
Check timestamp in "Last updated"

STEP 4: VERIFY CURRENCY STAYS USD
✓ Dropdown still shows USD
✓ Amounts still in USD
✓ No reset to EUR

STEP 5: TOGGLE BACK OFFLINE
Enable flight mode

STEP 6: VERIFY PERSISTENCE
Currency still USD
Rates still display (from earlier cache)

STEP 7: RAPID TOGGLE (3x)
Cycle: Online → Offline → Online → Offline → Online

Between each toggle:
  ✓ Check currency selection stable
  ✓ Observe for crashes
  ✓ Monitor memory (no leaks)
```

#### Pass Criteria
```
✓ Currency selection stable through toggles
✓ No crashes from rapid network changes
✓ Rates update when online
✓ Rates cached properly when offline
✓ No data loss
```

---

## PHASE 4: Reconnection Tests

### Test 4.1 Execution: New Rates Fetch When Going Online

**Duration**: 10 minutes  
**Network**: Starts OFFLINE, goes ONLINE  

#### Procedure
```
STEP 1: START OFFLINE
Flight mode ON
App running, ProfilePage visible
Rates display from cache
Example: 1 EUR = 1.96 BAM

STEP 2: NOTE CURRENT RATES & TIMESTAMP
Screenshot or note down:
  - All three rates
  - Exact timestamp
  
STEP 3: DISABLE FLIGHT MODE
Wait 3 seconds for network connection

STEP 4: WATCH FOR RATE UPDATE
Stay on ProfilePage
Watch Exchange Rates section

WITHIN 5-10 SECONDS, expect:
  ✓ Rates may change (if API values differ)
  ✓ Timestamp updates to new time
  ✓ No error messages

IF NO UPDATE OCCURS:
  ⚠️ Background fetch may not be implemented
  (See Issue #4 in specification)
  
  WORKAROUND: Restart app while online
    $ flutter run (Ctrl+C to close first)
    Rates should update on startup

STEP 5: VERIFY TIMESTAMP CHANGED
"Last updated" should now show:
  - Current date/time (within ±2 seconds)
  - Different from Step 2 timestamp
```

#### Expected Behavior
```
IDEAL (if periodic refresh implemented):
  Offline: timestamp = 2024-12-20 14:30:00
  Go online: wait 10s
  Online: timestamp = 2024-12-20 14:31:15
  ✓ Auto-refreshed!

CURRENT (startup-only):
  Offline: timestamp = 2024-12-20 14:30:00
  Go online: timestamp unchanged
  Restart app: timestamp = 2024-12-20 14:31:15
  ⚠️ Manual refresh required
```

#### Pass Criteria
```
✓ Timestamp updates (eventually)
✓ New rates fetch successfully
✓ Old cached rates replaced
✗ Currently: Requires app restart to fetch
(Future: Should auto-refresh)
```

---

### Test 4.2 Execution: UI Updates When Rates Arrive

**Duration**: 5 minutes  
**Network**: ONLINE after Test 4.1  

#### Procedure
```
STEP 1: GET BASELINE
Note current exchange rates on ProfilePage

STEP 2: FORCE API CALL
Method A - Restart app:
  $ flutter run (Ctrl+C first)
  New rates fetch at startup
  
Method B - Refresh button (if implemented):
  Look for 🔄 Refresh button
  Click to manually refresh

STEP 3: WATCH UI UPDATE
When new rates arrive:
  ✓ Rates section updates
  ✓ Numbers change (if API rates differ)
  ✓ Timestamp becomes current
  ✓ No loading spinner stuck

STEP 4: VERIFY PROVIDER REBUILD
Look for Provider.rebuild() evidence:
  ✓ UI smoothly updates
  ✓ No black screen
  ✓ No flash of old data
  ✓ Widget tree rebuilds cleanly

STEP 5: CURRENCY SELECTION UNCHANGED
After rates update:
  ✓ Selected currency still USD (or whatever chosen)
  ✓ No reset to EUR
  ✓ Amounts reconvert with new rates
```

#### Pass Criteria
```
✓ Rates update when fresh data arrives
✓ UI refreshes without crashes
✓ Timestamp reflects new fetch
✓ All currencies update together
```

---

## PHASE 5: Edge Case Tests

### Test 5.1 Execution: Empty Cache + Offline Startup

**Duration**: 5 minutes  
**Network**: OFFLINE  
**Cache**: EMPTY  

#### Procedure
```
STEP 1: CLEAR HIVE CACHE
Option A - DevTools:
  Open Hive inspector
  Delete 'expense_data' box
  Restart app
  
Option B - Code:
  In main.dart, clear before running:
    await Hive.deleteBoxFromDisk('expense_data');

STEP 2: ENABLE FLIGHT MODE
Airplane mode ON
Network disconnected

STEP 3: LAUNCH APP FRESH
$ flutter run -v

STEP 4: WAIT FOR INITIALIZATION
App should start

OBSERVE:
  ✓ No crash on startup
  ✓ ProfilePage loads
  ✓ Currency Settings visible

STEP 5: CHECK EXCHANGE RATES SECTION
Expected message:
  "Exchange rates will load when online..."
  
NOT expected:
  ✗ Blank/null section
  ✗ Error message
  ✗ Crash
  ✗ Unresponsive UI

STEP 6: VERIFY UI RESILIENCE
Can still:
  ✓ Tap dropdown (shows EUR as default)
  ✓ Navigate other pages
  ✓ No frozen/stuck state
```

#### Pass Criteria
```
✓ App launches without crash (no cache)
✓ Graceful fallback message displayed
✓ UI remains functional
✓ App doesn't attempt to fetch with no network
```

---

### Test 5.2 Execution: API Timeout (>10 seconds)

**Duration**: 20 minutes  
**Network**: ONLINE but throttled  
**Tools**: Need network throttling capability  

#### Setup: Charles Proxy Method (Recommended)
```
1. INSTALL CHARLES PROXY (Optional)
   Download: https://www.charlesproxy.com/

2. CONFIGURE DEVICE TO USE PROXY
   Android:
     Settings → Network → WiFi → Edit network
     Proxy → Manual
     Server: <Computer IP>
     Port: 8888
   
   iOS:
     Settings → WiFi → Current network → Configure Proxy
     Manual → <Computer IP>, Port 8888

3. IN CHARLES:
   Tools → Throttle Settings
   Set limit: 1 KB/s (or <1 KB/s)

4. LAUNCH APP:
   $ flutter run -v
   
   App will make API call with severe throttle
   Expect timeout after ~10 seconds
```

#### Setup: Android Emulator Built-in Throttle
```
1. OPEN EMULATOR SETTINGS
   Extended Controls (3-dot menu)

2. NETWORK
   Throttle: 1G or 2G (very slow)
   
3. LAUNCH APP:
   $ flutter run -v

4. OBSERVE: Timeout after 10 seconds
```

#### Procedure
```
STEP 1: THROTTLE NETWORK (Use method above)

STEP 2: CLEAR HIVE (no cache to fall back on)
Hive delete 'EXCHANGE_RATES' key

STEP 3: LAUNCH APP
$ flutter run -v

STEP 4: OBSERVE STARTUP
Watch Flutter output

EXPECT (in terminal):
  Around 10-11 seconds:
  "Error fetching exchange rates: SocketException: Operation timed out"

EXPECT (in UI):
  ✓ Splash screen appears
  ✓ App initializes
  ✓ Around 10s: Rates section shows fallback message
  ✓ No error popup to user
  ✓ App remains functional

STEP 5: VERIFY UI STATE
ProfilePage eventually loads showing:
  ✓ Currency dropdown works
  ✓ "Exchange rates will load when online..." message
  ✓ No spinner/loading animation stuck
  ✓ App responsive

STEP 6: RESTORE NETWORK
Remove throttle, reset proxy
Wait 5 seconds

STEP 7: RESTART APP
$ flutter run

Should now:
  ✓ Fetch rates successfully (from fast network)
  ✓ Update UI with new rates
```

#### Pass Criteria
```
✓ Timeout occurs at ~10 seconds (not earlier/later)
✓ No crash or exception (caught in try-catch)
✓ App handles gracefully
✓ Eventually fetches when network restored
```

---

### Test 5.3 Execution: Malformed API Response

**Duration**: 8 minutes  
**Tools**: Need HTTP mocking capability  

#### Setup: Using Mockito (If Available)
```dart
// Create mock API response:
// In test file:

import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends Mock implements http.Client {}

void main() {
  test('API returns malformed rates', () async {
    final mockClient = MockHttpClient();
    
    // Mock malformed response
    when(mockClient.get(any)).thenAnswer((_) async => 
      http.Response(
        '{"base": "EUR", "rates": "not_an_object"}', 
        200
      )
    );
    
    // Test should handle gracefully
  });
}
```

#### Setup: Manual Testing (Without Framework)
```
1. CREATE MOCK SERVER (Optional)
   Can use Python Flask or Node.js
   
   Python example:
   from flask import Flask
   app = Flask(__name__)
   
   @app.route('/v4/latest/EUR')
   def bad_rates():
       return '{"base": "EUR", "rates": [1, 2, 3]}'  # Array instead of object
   
   Run: python app.py

2. POINT APP TO MOCK SERVER
   Edit exchange_rate_service.dart:
   static const String _baseUrl = 'http://localhost:5000';
   
   $ flutter run -v

3. OBSERVE: App should handle error
```

#### Procedure - Without Mocking Framework
```
STEP 1: CLOSE HIVE CACHE
Delete EXCHANGE_RATES key

STEP 2: EDIT API URL TEMPORARILY
exchange_rate_service.dart:
  Change _baseUrl to invalid endpoint
  Example: "https://api.invalid-domain-12345.com"

STEP 3: LAUNCH APP
$ flutter run -v

STEP 4: OBSERVE ERROR HANDLING
Expect (in terminal):
  "Error fetching exchange rates: ..."
  
Expect (in UI):
  ✓ App doesn't crash
  ✓ ProfilePage loads
  ✓ Rates section shows fallback message
  ✓ Currency dropdown works
  ✓ No null reference exception

STEP 5: REVERT API URL
exchange_rate_service.dart:
  Restore _baseUrl to correct endpoint

STEP 6: RESTART
Rates should fetch and display correctly
```

#### Pass Criteria
```
✓ Malformed API response caught
✓ No unhandled exception
✓ App remains functional
✓ Graceful degradation to cached/fallback state
```

---

## TESTING CHECKLIST

### Pre-Testing
```
□ Review specification document
□ Understand 5 test phases
□ Gather required tools
□ Create test data (expenses/income for Tests 2.5)
□ Set up network throttling capability (for Test 5.2)
□ Have console/terminal access for logs
```

### During Testing
```
Phase 1 (Online Setup):
  □ Test 1.1: Fetch online
  □ Test 1.2: Verify Hive cache

Phase 2 (Offline Functionality):
  □ Test 2.1: App loads offline
  □ Test 2.2: Cached rates display
  □ Test 2.3: Currency selector works
  □ Test 2.4: Select different currency
  □ Test 2.5: Amounts display correctly

Phase 3 (Offline Persistence):
  □ Test 3.1: Currency persists (WILL FAIL due to bug)
  □ Test 3.2: Network toggle stability

Phase 4 (Reconnection):
  □ Test 4.1: New rates fetch online
  □ Test 4.2: UI updates with new rates

Phase 5 (Edge Cases):
  □ Test 5.1: Empty cache + offline
  □ Test 5.2: API timeout handling
  □ Test 5.3: Malformed API response
```

### Post-Testing
```
□ Document all failures
□ Collect console logs
□ Note exact error messages
□ Screenshot UI state for failures
□ Verify all identified bugs from specification
□ Prepare bug reports with reproduction steps
```

---

## Quick Reference: Console Commands

```bash
# Clear Hive (clean slate)
$ flutter run --debug
# In main.dart, add before main():
# await Hive.deleteBoxFromDisk('expense_data');

# View logs
$ flutter logs

# Enable verbose output
$ flutter run -v

# Kill app process
$ adb shell am force-stop com.example.app_1

# View Hive data
$ flutter pub add hive_viewer  # (then use in app)

# Network throttle (Android emulator)
# Tools → Extended controls → Network → Limit

# View DevTools
# Check terminal output for link: http://127.0.0.1:PORT
```

---

## Success Metrics

### Must Pass
- Test 1.1 ✅
- Test 1.2 ✅
- Test 2.1 ✅
- Test 2.2 ✅
- Test 2.3 ✅
- Test 2.4 ✅
- Test 4.1/4.2 (with app restart) ✅
- Test 5.1 ✅

### Will Fail (Known Bugs)
- Test 3.1 ❌ (Currency persist bug)
- Test 4.1 (if auto-refresh not implemented) ⚠️

### Should Pass
- Test 2.5 ⚠️ (Income display hardcoded to EUR)
- Test 3.2 ✅
- Test 5.2 ✅
- Test 5.3 ✅

---

## Report Template

After completing all tests, fill this template:

```
Test Execution Report
═══════════════════════════════════════
Date: YYYY-MM-DD
Tester: [Name]
App Version: [Version from pubspec.yaml]
Device: [Android/iOS/Emulator model]
Flutter Version: [3.10.3 or later]

PHASE 1 - ONLINE SETUP
─────────────────────
Test 1.1 (Fetch): [PASS/FAIL] Details:
Test 1.2 (Cache): [PASS/FAIL] Details:

PHASE 2 - OFFLINE MODE
─────────────────────
Test 2.1: [PASS/FAIL]
Test 2.2: [PASS/FAIL]
Test 2.3: [PASS/FAIL]
Test 2.4: [PASS/FAIL]
Test 2.5: [PASS/FAIL]

PHASE 3 - PERSISTENCE
─────────────────────
Test 3.1: [FAIL - Expected] Bug confirmed
Test 3.2: [PASS/FAIL]

PHASE 4 - RECONNECTION
─────────────────────
Test 4.1: [PASS/FAIL] Details:
Test 4.2: [PASS/FAIL]

PHASE 5 - EDGE CASES
────────────────────
Test 5.1: [PASS/FAIL]
Test 5.2: [PASS/FAIL]
Test 5.3: [PASS/FAIL]

SUMMARY
──────
Total Tests: 13
Passed: __
Failed: __
Pass Rate: __%

BUGS CONFIRMED
──────────────
1. Currency persist bug (Test 3.1) ❌
2. Income hardcoded EUR (Test 2.5) ⚠️
3. [Other issues found]

RECOMMENDATIONS
────────────────
1. Fix currency persistence (HIGH priority)
2. Fix income display (MEDIUM priority)
3. [Others]
```

