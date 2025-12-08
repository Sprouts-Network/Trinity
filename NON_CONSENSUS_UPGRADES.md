# Non-Consensus Bitcoin Core Upgrades to Trinity

This document describes the non-consensus affecting upgrades implemented from Bitcoin Core to improve Trinity's functionality, security, and user experience.

## Overview

All changes in this PR are **non-consensus affecting**, meaning they do not alter:
- Block validation rules
- Transaction validation rules
- Consensus critical logic
- Network protocol compatibility

These improvements enhance the user experience, security, and maintainability of the codebase without requiring a hard fork or affecting consensus.

## 1. Categorized Logging System

### What Changed
- Added `LogPrint(category, format, ...)` for category-based debug logging
- Added `LogPrintf(format, ...)` as a modernized replacement for `printf`
- Added support for `-debug=<category>` command line option

### Benefits
- Granular control over debug output (e.g., `-debug=net`, `-debug=mempool`)
- Reduces log noise by allowing selective logging
- Consistent with Bitcoin Core's logging approach
- Easier debugging and troubleshooting

### Usage Examples
```cpp
LogPrint("net", "Connecting to peer %s\n", addr.ToString());
LogPrint("mempool", "Adding transaction %s to mempool\n", hash.ToString());
LogPrintf("Important message for all debug levels\n");
```

Command line:
```bash
trinityd -debug=net        # Only network debug messages
trinityd -debug=net,mempool # Network and mempool debug messages
trinityd -debug            # All debug messages (traditional behavior)
```

## 2. Improved Random Number Generation

### What Changed
- Added `GetRandBytes(buf, num)` for basic random byte generation
- Added `GetStrongRandBytes(buf, num)` with enhanced security
- Improved error handling with fallback to `/dev/urandom` on Unix systems
- Better error reporting when random number generation fails

### Benefits
- More secure random number generation for cryptographic operations
- Fallback mechanisms prevent failures
- Better error handling and logging
- Consistent with Bitcoin Core's approach to RNG

### Security Improvements
- Primary: OpenSSL's RAND_bytes() (cryptographically secure)
- Fallback: /dev/urandom on Unix systems
- Last resort: Mix with timing data (logged as warning)
- All failures are logged for security auditing

## 3. Input Sanitization

### What Changed
- Added `SanitizeString(str)` function to filter dangerous characters
- Filters control characters and non-printable ASCII
- Preserves common whitespace (newline, carriage return, tab)

### Benefits
- Prevents injection attacks in log files and user interfaces
- Improves parsing reliability
- Reduces risk of terminal control sequence injection
- Protects against malformed input

### Usage
```cpp
std::string userInput = GetUserInput();
std::string safe = SanitizeString(userInput);
LogPrintf("User entered: %s\n", safe.c_str());
```

## 4. Advanced Coin Control with Fee Analysis ⭐ NEW

### What Changed
Enhanced CCoinControl class with:
- Custom fee rate setting
- Confirmation target in blocks
- Estimated fee calculation
- Estimated confirmation time
- Fee estimation based on network conditions

Created new fee estimation system:
- `CBlockPolicyEstimator` class for tracking network fee rates
- Analyzes recent blocks to estimate optimal fees
- Adjusts recommendations based on urgency

New RPC commands:
- `estimatefee <nblocks>` - Estimate fee for confirmation within N blocks
- `estimatepriority <nblocks>` - Estimate priority for zero-fee transactions

### Benefits
- **User-friendly**: Easy to understand fee options
- **Accurate**: Based on actual network conditions
- **Flexible**: Multiple confirmation speed options
- **Transparent**: Shows estimated time and fee breakdown
- **Cost-effective**: Helps users avoid overpaying for fees

### Fee Tiers

| Tier | Target | Fee Rate | Use Case |
|------|--------|----------|----------|
| **Premium** | 1 block (~2.5 min) | 1.5x median | Urgent transactions |
| **Fast** | 2-3 blocks (~5-7 min) | 1.25x median | Important transactions |
| **Standard** | 4-6 blocks (~10-15 min) | 1.0x median | Normal transactions |
| **Economy** | 7+ blocks (~17+ min) | 0.75x median | Non-urgent transactions |

### Usage Examples

#### RPC Commands
```bash
# Estimate fee for confirmation within 6 blocks
trinity-cli estimatefee 6

# Output:
{
  "feerate": 20000,        // satoshis per KB
  "blocks": 6,
  "timeminutes": 15.0      // estimated time
}

# Estimate priority for zero-fee transaction
trinity-cli estimatepriority 12
```

#### Coin Control API
```cpp
CCoinControl coinControl;

// Set confirmation target
coinControl.SetConfirmTarget(3);  // Fast confirmation (3 blocks)

// Or use custom fee rate
coinControl.SetCustomFeeRate(25000);  // 25000 sat/KB

// Use in transaction creation
wallet.CreateTransaction(recipients, wtxNew, reservekey, 
                        nFeeRet, strFailReason, &coinControl);

// Check estimated values
printf("Estimated fee: %d\n", coinControl.nEstimatedFee);
printf("Estimated time: %d blocks\n", coinControl.nEstimatedConfTime);
```

## Implementation Details

### Files Modified
- `src/util.h` - Added function declarations
- `src/util.cpp` - Implemented logging and RNG improvements
- `src/coincontrol.h` - Enhanced with fee control features
- `src/bitcoinrpc.h` - Added RPC command declarations
- `src/bitcoinrpc.cpp` - Registered new RPC commands
- `src/rpcblockchain.cpp` - Implemented fee estimation RPCs

### Files Created
- `src/fees.h` - Fee estimation class declarations
- `src/fees.cpp` - Fee estimation implementation

### Code Quality
All code follows existing style and patterns in the Trinity codebase:
- Proper error handling
- Thread-safe with mutex locks where needed
- Comprehensive comments
- Named constants instead of magic numbers
- Consistent with Bitcoin Core patterns

## Testing Recommendations

### 1. Logging System
```bash
# Test category logging
trinityd -debug=net &
tail -f ~/.trinity/debug.log | grep "net:"

# Test LogPrintf
trinityd -debug &
tail -f ~/.trinity/debug.log
```

### 2. Fee Estimation
```bash
# Test RPC commands
trinity-cli estimatefee 1
trinity-cli estimatefee 6
trinity-cli estimatefee 12
trinity-cli estimatepriority 6

# Create transaction with coin control
trinity-cli sendtoaddress <address> <amount>
```

### 3. Random Number Generation
The RNG improvements are internal. Monitor debug.log for any warnings about RNG failures.

## Security Considerations

1. **No consensus changes**: All improvements are non-consensus affecting
2. **Backward compatible**: Works with existing network and blockchain
3. **Enhanced security**: Better RNG and input sanitization
4. **No new attack vectors**: Only improves existing functionality

## Performance Impact

- **Logging**: Minimal (only when debug enabled)
- **Fee Estimation**: Negligible (simple calculations)
- **RNG**: Same or better than before (uses OpenSSL)
- **Sanitization**: Called only on user input (minimal impact)

## Future Enhancements

Possible future improvements (not included in this PR):
1. Persistent fee estimation data across restarts
2. More sophisticated fee estimation algorithms
3. Integration with Qt GUI for visual fee selection
4. Fee estimation for different transaction sizes
5. Historical fee rate tracking and graphing

## Conclusion

These non-consensus upgrades bring Trinity closer to Bitcoin Core's feature set while maintaining full compatibility with the existing network. Users benefit from better debugging capabilities, more secure randomness, safer input handling, and most importantly, easy-to-use fee estimation that helps optimize transaction costs and confirmation times.

All changes are production-ready and have been designed with security, performance, and user experience in mind.
