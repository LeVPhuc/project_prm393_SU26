package com.vunven.backend.repository;

import com.vunven.backend.entity.Challenge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ChallengeRepository extends JpaRepository<Challenge, String> {
    List<Challenge> findByUserId(String userId);
    List<Challenge> findByWalletIdAndStatus(String walletId, String status);
}
