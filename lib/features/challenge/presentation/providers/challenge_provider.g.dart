// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$challengeListNotifierHash() =>
    r'8868595dcb15da9c5b70dcd79ee58f8dda73b807';

/// Notifier quản lý danh sách Thách đấu trong hệ thống.
///
/// Hỗ trợ nạp dữ liệu bất đồng bộ và cung cấp các hàm nghiệp vụ:
/// tạo cược, cập nhật chi tiêu, giải tỏa cược khi hoàn thành/thất bại.
///
/// Copied from [ChallengeListNotifier].
@ProviderFor(ChallengeListNotifier)
final challengeListNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      ChallengeListNotifier,
      List<ChallengeModel>
    >.internal(
      ChallengeListNotifier.new,
      name: r'challengeListNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$challengeListNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChallengeListNotifier =
    AutoDisposeAsyncNotifier<List<ChallengeModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
