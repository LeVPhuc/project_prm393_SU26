package com.vunven.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_achievements")
@IdClass(UserAchievementId.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserAchievement {
    @Id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "achievement_id", nullable = false)
    private Achievement achievement;

    @Builder.Default
    @Column(name = "unlocked_at", nullable = false)
    private LocalDateTime unlockedAt = LocalDateTime.now();
}
