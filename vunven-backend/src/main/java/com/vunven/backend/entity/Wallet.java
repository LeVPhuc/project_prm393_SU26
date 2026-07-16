package com.vunven.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "wallets")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Wallet {
    @Id
    @Column(length = 50)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Builder.Default
    @Column(nullable = false)
    private Double balance = 0.0;

    @Builder.Default
    @Column(name = "frozen_balance", nullable = false)
    private Double frozenBalance = 0.0;

    @Column(nullable = false, length = 100)
    private String name;

    @Builder.Default
    @Column(length = 10)
    private String currency = "VND";

    @Column(length = 50)
    private String icon;

    @Column(name = "color_index")
    private Integer colorIndex;

    @Column(length = 50)
    private String type;

    @Builder.Default
    @Column(name = "is_default")
    private Boolean isDefault = false;

    @Builder.Default
    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();
}
