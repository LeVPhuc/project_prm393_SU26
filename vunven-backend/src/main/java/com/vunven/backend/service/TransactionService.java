package com.vunven.backend.service;

import com.vunven.backend.dto.TransactionRequest;
import com.vunven.backend.entity.*;
import com.vunven.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class TransactionService {
    @Autowired
    private TransactionRepository transactionRepository;
    @Autowired
    private WalletRepository walletRepository;
    @Autowired
    private CategoryRepository categoryRepository;
    @Autowired
    private ChallengeRepository challengeRepository;
    @Autowired
    private FrozenFundRepository frozenFundRepository;

    @Transactional
    public Transaction createTransaction(TransactionRequest request) {
        Wallet wallet = walletRepository.findById(request.getWalletId())
                .orElseThrow(() -> new RuntimeException("Wallet not found"));
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Category not found"));

        Challenge challenge = null;
        if (request.getChallengeId() != null) {
            challenge = challengeRepository.findById(request.getChallengeId()).orElse(null);
        }

        Transaction transaction = Transaction.builder()
                .id(request.getId() != null ? request.getId() : UUID.randomUUID().toString())
                .wallet(wallet)
                .category(category)
                .categoryEnum(request.getCategoryEnum())
                .challenge(challenge)
                .amount(request.getAmount())
                .type(request.getType())
                .title(request.getTitle())
                .note(request.getNote())
                .date(request.getDate() != null ? request.getDate() : LocalDateTime.now())
                .createdAt(LocalDateTime.now())
                .build();

        // 1. Cập nhật số dư ví
        if ("income".equalsIgnoreCase(transaction.getType())) {
            wallet.setBalance(wallet.getBalance() + transaction.getAmount());
        } else if ("expense".equalsIgnoreCase(transaction.getType())) {
            wallet.setBalance(wallet.getBalance() - transaction.getAmount());

            // 2. Kiểm tra nếu giao dịch này thuộc thử thách nào đó
            // Hoặc ví có thử thách active nào đang theo dõi danh mục chi tiêu này
            List<Challenge> activeChallenges = challengeRepository.findByWalletIdAndStatus(wallet.getId(), "active");
            for (Challenge ch : activeChallenges) {
                // Kiểm tra xem danh mục có khớp không
                boolean isCategoryMatch = false;
                if (ch.getCategoryIds() == null || ch.getCategoryIds().trim().isEmpty() || "[]".equals(ch.getCategoryIds().trim())) {
                    isCategoryMatch = true; // Rỗng tức là theo dõi toàn bộ danh mục của ví đó
                } else {
                    // Đơn giản hóa việc kiểm tra chuỗi JSON dạng ["food"]
                    String catIdLower = category.getId().toLowerCase();
                    if (ch.getCategoryIds().toLowerCase().contains(catIdLower)) {
                        isCategoryMatch = true;
                    }
                }

                if (isCategoryMatch) {
                    // Gán challenge vào giao dịch nếu chưa có
                    if (transaction.getChallenge() == null) {
                        transaction.setChallenge(ch);
                    }

                    double nextSpent = ch.getActualSpent() + transaction.getAmount();
                    ch.setActualSpent(nextSpent);

                    if (nextSpent > ch.getSpendLimit()) {
                        ch.setCurrentViolations(ch.getCurrentViolations() + 1);
                        if (ch.getShields() > 0) {
                            ch.setShields(ch.getShields() - 1);
                            // Được bảo vệ bằng khiên, không đánh dấu thất bại
                        } else {
                            ch.setStatus("failed");
                            // Phạt trừ tiền cược khỏi ví
                            wallet.setBalance(wallet.getBalance() - ch.getBetAmount());
                            wallet.setFrozenBalance(Math.max(0.0, wallet.getFrozenBalance() - ch.getBetAmount()));

                            // Cập nhật trạng thái quỹ đóng băng liên quan
                            List<FrozenFund> funds = frozenFundRepository.findByChallengeId(ch.getId());
                            for (FrozenFund fund : funds) {
                                if ("locked".equals(fund.getStatus())) {
                                    fund.setStatus("releasedLost");
                                    fund.setReleasedAt(LocalDateTime.now());
                                    frozenFundRepository.save(fund);
                                }
                            }
                        }
                    }
                    challengeRepository.save(ch);
                }
            }
        }

        walletRepository.save(wallet);
        return transactionRepository.save(transaction);
    }

    @Transactional
    public void deleteTransaction(String id) {
        Transaction transaction = transactionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Transaction not found"));

        Wallet wallet = transaction.getWallet();
        // Hoàn tác số dư ví
        if ("income".equalsIgnoreCase(transaction.getType())) {
            wallet.setBalance(wallet.getBalance() - transaction.getAmount());
        } else if ("expense".equalsIgnoreCase(transaction.getType())) {
            wallet.setBalance(wallet.getBalance() + transaction.getAmount());
        }

        // Hoàn tác tiến trình challenge nếu có
        Challenge ch = transaction.getChallenge();
        if (ch != null) {
            ch.setActualSpent(Math.max(0.0, ch.getActualSpent() - transaction.getAmount()));
            challengeRepository.save(ch);
        }

        walletRepository.save(wallet);
        transactionRepository.delete(transaction);
    }
}
