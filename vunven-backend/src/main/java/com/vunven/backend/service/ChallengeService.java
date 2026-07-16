package com.vunven.backend.service;

import com.vunven.backend.entity.*;
import com.vunven.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class ChallengeService {
    @Autowired
    private ChallengeRepository challengeRepository;
    @Autowired
    private WalletRepository walletRepository;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private FrozenFundRepository frozenFundRepository;

    @Transactional
    public Challenge createChallenge(Challenge challenge) {
        User user = userRepository.findById(challenge.getUser().getId())
                .orElseThrow(() -> new RuntimeException("User not found"));
        Wallet wallet = walletRepository.findById(challenge.getWallet().getId())
                .orElseThrow(() -> new RuntimeException("Wallet not found"));

        challenge.setUser(user);
        challenge.setWallet(wallet);

        if (challenge.getId() == null) {
            challenge.setId(UUID.randomUUID().toString());
        }
        if (challenge.getStatus() == null) {
            challenge.setStatus("active");
        }

        Challenge savedChallenge = challengeRepository.save(challenge);

        // Đóng băng tiền nếu có đặt cược
        if (challenge.getBetAmount() != null && challenge.getBetAmount() > 0) {
            wallet.setFrozenBalance(wallet.getFrozenBalance() + challenge.getBetAmount());
            walletRepository.save(wallet);

            FrozenFund fund = FrozenFund.builder()
                    .id(UUID.randomUUID().toString())
                    .wallet(wallet)
                    .challenge(savedChallenge)
                    .amount(challenge.getBetAmount())
                    .status("locked")
                    .createdAt(LocalDateTime.now())
                    .build();
            frozenFundRepository.save(fund);
        }

        return savedChallenge;
    }

    @Transactional
    public Challenge updateChallengeStatus(String id, String newStatus) {
        Challenge challenge = challengeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Challenge not found"));

        String oldStatus = challenge.getStatus();
        if (oldStatus.equalsIgnoreCase(newStatus)) {
            return challenge;
        }

        challenge.setStatus(newStatus.toLowerCase());
        Wallet wallet = challenge.getWallet();

        if (challenge.getBetAmount() != null && challenge.getBetAmount() > 0) {
            if ("active".equalsIgnoreCase(oldStatus) || "pending".equalsIgnoreCase(oldStatus)) {
                if ("completed".equalsIgnoreCase(newStatus)) {
                    // Hoàn thành: Giải tỏa đóng băng (giảm frozen_balance, tổng balance không đổi)
                    wallet.setFrozenBalance(Math.max(0.0, wallet.getFrozenBalance() - challenge.getBetAmount()));
                    walletRepository.save(wallet);

                    updateFrozenFundStatus(challenge.getId(), "releasedReturned");
                } else if ("failed".equalsIgnoreCase(newStatus) || "forfeited".equalsIgnoreCase(newStatus)) {
                    // Thất bại/Bỏ cuộc: Mất tiền (giảm cả balance và frozen_balance)
                    wallet.setBalance(wallet.getBalance() - challenge.getBetAmount());
                    wallet.setFrozenBalance(Math.max(0.0, wallet.getFrozenBalance() - challenge.getBetAmount()));
                    walletRepository.save(wallet);

                    updateFrozenFundStatus(challenge.getId(), "releasedLost");
                }
            }
        }

        return challengeRepository.save(challenge);
    }

    private void updateFrozenFundStatus(String challengeId, String status) {
        List<FrozenFund> funds = frozenFundRepository.findByChallengeId(challengeId);
        for (FrozenFund fund : funds) {
            if ("locked".equalsIgnoreCase(fund.getStatus())) {
                fund.setStatus(status);
                fund.setReleasedAt(LocalDateTime.now());
                frozenFundRepository.save(fund);
            }
        }
    }
}
