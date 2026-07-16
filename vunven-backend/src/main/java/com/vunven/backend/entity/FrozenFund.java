package com.vunven.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "frozen_funds")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FrozenFund {
    @Id
    @Column(length = 50)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "wallet_id", nullable = false)
    private Wallet wallet;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "challenge_id", nullable = false)
    private Challenge challenge;

    @Column(nullable = false)
    private Double amount;

    @Column(nullable = false, length = 20)
    private String status; // locked, releasedReturned, releasedLost

    @Builder.Default
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "released_at")
    private LocalDateTime releasedAt;
}
