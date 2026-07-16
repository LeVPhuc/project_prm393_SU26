package com.vunven.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "transactions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Transaction {
    @Id
    @Column(length = 50)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "wallet_id", nullable = false)
    private Wallet wallet;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(name = "category_enum", length = 50)
    private String categoryEnum; // compatibility with food, transport...

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "challenge_id")
    private Challenge challenge; // Nullable

    @Column(nullable = false)
    private Double amount;

    @Column(nullable = false, length = 20)
    private String type; // income, expense

    @Column(nullable = false, length = 200)
    private String title;

    @Column(columnDefinition = "NVARCHAR(MAX)")
    private String note;

    @Column(nullable = false)
    private LocalDateTime date;

    @Builder.Default
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
