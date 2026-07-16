package com.vunven.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification {
    @Id
    @Column(length = 50)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(columnDefinition = "NVARCHAR(MAX)")
    private String body;

    @Builder.Default
    @Column(length = 20)
    private String status = "pending"; // pending, delivered, read

    @Column(name = "scheduled_at", nullable = false)
    private LocalDateTime scheduledAt;
}
