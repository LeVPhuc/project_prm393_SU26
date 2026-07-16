package com.vunven.backend.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "achievements")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Achievement {
    @Id
    @Column(length = 50)
    private String id;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(columnDefinition = "NVARCHAR(MAX)")
    private String description;

    @Column(name = "icon_key", length = 50)
    private String iconKey;
}
