enum RewardedAdReward { doubleIncome, doubleOffline, freeRepair }

/// Mock rewarded-ad adapter. No forced ads are shown in the MVP.
class AdService {
  Future<bool> showRewarded(RewardedAdReward reward) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return true;
  }
}
