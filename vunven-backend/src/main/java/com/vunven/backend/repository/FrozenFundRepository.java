package com.vunven.backend.repository;

import com.vunven.backend.entity.FrozenFund;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface FrozenFundRepository extends JpaRepository<FrozenFund, String> {
    List<FrozenFund> findByWalletId(String walletId);
    List<FrozenFund> findByChallengeId(String challengeId);
}
