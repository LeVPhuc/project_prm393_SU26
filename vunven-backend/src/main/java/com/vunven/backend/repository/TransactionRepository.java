package com.vunven.backend.repository;

import com.vunven.backend.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, String> {
    List<Transaction> findByWalletId(String walletId);
    List<Transaction> findByChallengeId(String challengeId);
    List<Transaction> findByWalletUserId(String userId);
}
