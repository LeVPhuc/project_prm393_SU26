package com.vunven.backend.repository;

import com.vunven.backend.entity.Wallet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface WalletRepository extends JpaRepository<Wallet, String> {
    List<Wallet> findByUserId(String userId);
}
