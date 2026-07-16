package com.vunven.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "challenges")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Challenge {
    @Id
    @Column(length = 50)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "wallet_id", nullable = false)
    private Wallet wallet;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(columnDefinition = "NVARCHAR(MAX)")
    private String description;

    @Column(length = 50)
    private String icon;

    @Builder.Default
    @Column(name = "spend_limit", nullable = false)
    private Double spendLimit = 0.0;

    @Builder.Default
    @Column(name = "bet_amount", nullable = false)
    private Double betAmount = 0.0;

    @Column(name = "start_date", nullable = false)
    private LocalDateTime startDate;

    @Column(name = "end_date", nullable = false)
    private LocalDateTime endDate;

    @Builder.Default
    @Column(length = 20)
    private String status = "active"; // pending, active, completed, failed, forfeited

    @Builder.Default
    @Column(name = "actual_spent")
    private Double actualSpent = 0.0;

    @Column(name = "category_ids", columnDefinition = "NVARCHAR(MAX)")
    private String categoryIds; // JSON string array: '["food", "shopping"]'

    @Builder.Default
    @Column(name = "current_streak")
    private Integer currentStreak = 0;

    @Builder.Default
    private Integer shields = 0;

    @Builder.Default
    @Column(name = "max_violations")
    private Integer maxViolations = 1;

    @Builder.Default
    @Column(name = "current_violations")
    private Integer currentViolations = 0;

    @Builder.Default
    @Column(name = "is_ai_duel")
    private Boolean isAiDuel = false;

    @Builder.Default
    @Column(name = "ai_spent")
    private Double aiSpent = 0.0;

    @Column(name = "daily_spending", columnDefinition = "NVARCHAR(MAX)")
    private String dailySpending; // JSON string array of doubles: '[120000.0, 45000.0]'
}
