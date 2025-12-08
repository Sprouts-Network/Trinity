// Copyright (c) 2009-2014 The Bitcoin developers  
// Distributed under the MIT/X11 software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "fees.h"
#include "core.h"
#include "main.h"
#include "util.h"

#include <algorithm>
#include <vector>

using namespace std;

CBlockPolicyEstimator::CBlockPolicyEstimator(int64 minFeeRate)
    : nMinFeeRate(minFeeRate), nDefaultFeeRate(20000)
{
}

void CBlockPolicyEstimator::ProcessBlock(int nBlockHeight, const std::vector<const CTransaction*>& vtx)
{
    LOCK(cs_feeEstimator);
    
    if (vtx.empty())
        return;
    
    // Calculate fees for this block
    int64 nTotalFees = 0;
    int nTxCount = 0;
    
    for (vector<const CTransaction*>::const_iterator it = vtx.begin(); it != vtx.end(); ++it)
    {
        const CTransaction& tx = **it;
        
        // Skip coinbase
        if (tx.IsCoinBase())
            continue;
            
        // For now, we'll use a simple heuristic
        // In a real implementation, we'd track actual fees paid
        nTxCount++;
    }
    
    if (nTxCount > 0) {
        // Store block statistics
        mapBlockTxCount[nBlockHeight] = nTxCount;
        
        // Clean up old data
        if (mapBlockTxCount.size() > HISTORY_BLOCKS) {
            int nOldestBlock = nBlockHeight - HISTORY_BLOCKS;
            mapBlockTxCount.erase(nOldestBlock);
            mapBlockFees.erase(nOldestBlock);
        }
    }
}

int64 CBlockPolicyEstimator::CalculateMedianFee(int nBlocks) const
{
    LOCK(cs_feeEstimator);
    
    if (mapBlockFees.empty())
        return nDefaultFeeRate;
    
    vector<int64> vFees;
    for (map<int, int64>::const_iterator it = mapBlockFees.begin(); 
         it != mapBlockFees.end(); ++it)
    {
        vFees.push_back(it->second);
    }
    
    if (vFees.empty())
        return nDefaultFeeRate;
    
    sort(vFees.begin(), vFees.end());
    
    // Return median
    return vFees[vFees.size() / 2];
}

int64 CBlockPolicyEstimator::EstimateFee(int nBlocks) const
{
    LOCK(cs_feeEstimator);
    
    // Sanity check
    if (nBlocks <= 0)
        nBlocks = 1;
    if (nBlocks > 25)
        nBlocks = 25;
    
    // If we don't have enough data, return default
    if (mapBlockFees.size() < 3)
        return nDefaultFeeRate;
    
    // Calculate median fee from recent blocks
    int64 nMedianFee = CalculateMedianFee(nBlocks);
    
    // Adjust based on confirmation target
    // Faster confirmation = higher fee
    int64 nEstimate = nMedianFee;
    
    if (nBlocks <= 1) {
        // Next block - add 50% premium
        nEstimate = nMedianFee * 3 / 2;
    } else if (nBlocks <= 3) {
        // Within 3 blocks - add 25% premium  
        nEstimate = nMedianFee * 5 / 4;
    } else if (nBlocks <= 6) {
        // Within 6 blocks - use median
        nEstimate = nMedianFee;
    } else {
        // More than 6 blocks - can use lower fee
        nEstimate = nMedianFee * 3 / 4;
    }
    
    // Ensure minimum
    if (nEstimate < nMinFeeRate)
        nEstimate = nMinFeeRate;
    
    return nEstimate;
}

int CBlockPolicyEstimator::EstimateConfirmationTime(int64 nFeeRate) const
{
    LOCK(cs_feeEstimator);
    
    // If fee rate is very low, expect long wait
    if (nFeeRate < nMinFeeRate)
        return 25;  // Maximum blocks we track
    
    int64 nMedianFee = CalculateMedianFee(6);
    
    // Estimate confirmation time based on fee rate
    if (nFeeRate >= nMedianFee * 3 / 2) {
        return 1;  // Next block
    } else if (nFeeRate >= nMedianFee * 5 / 4) {
        return 3;  // Within 3 blocks
    } else if (nFeeRate >= nMedianFee) {
        return 6;  // Within 6 blocks  
    } else if (nFeeRate >= nMedianFee * 3 / 4) {
        return 12; // Within 12 blocks
    } else {
        return 25; // More than 25 blocks
    }
}

void CBlockPolicyEstimator::Write()
{
    // TODO: Implement persistence
}

void CBlockPolicyEstimator::Read()
{
    // TODO: Implement persistence
}

// CCoinControlFeatures implementation

int64 CCoinControlFeatures::GetOptimalFee(size_t nTxSize) const
{
    // If custom fee is set, use it
    if (nCustomFeeRate > 0) {
        return (nCustomFeeRate * nTxSize) / 1000;
    }
    
    // Otherwise, estimate based on confirmation target
    int64 nFeeRate = feeEstimator.EstimateFee(nConfTarget);
    
    // Calculate total fee
    int64 nFee = (nFeeRate * nTxSize) / 1000;
    
    // Ensure minimum
    int64 nMinFee = (nMinFeeRate * nTxSize) / 1000;
    if (nFee < nMinFee)
        nFee = nMinFee;
    
    return nFee;
}

int CCoinControlFeatures::EstimateConfTime(int64 nFeeRate) const
{
    return feeEstimator.EstimateConfirmationTime(nFeeRate);
}

// Global fee estimator instance
CBlockPolicyEstimator feeEstimator(1000);

// Helper functions

std::string FormatFeeRate(int64 nFeeRate)
{
    // Format as satoshis per KB
    return strprintf("%d sat/KB", nFeeRate);
}

unsigned int EstimateTxSize(unsigned int nInputs, unsigned int nOutputs)
{
    /**
     * Estimate transaction size in bytes:
     * - Each input: ~180 bytes (148 bytes + overhead)
     * - Each output: ~34 bytes
     * - Transaction overhead: ~10 bytes
     */
    return nInputs * 180 + nOutputs * 34 + 10;
}
