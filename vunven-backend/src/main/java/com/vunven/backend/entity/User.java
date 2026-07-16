package com.vunven.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    @Id
    @Column(length = 50)
    private String id;

    @Column(nullable = false, length = 100)
    private String username;

    @Builder.Default
    @Column(name = "streak_count")
    private Integer streakCount = 0;

    @Builder.Default
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
