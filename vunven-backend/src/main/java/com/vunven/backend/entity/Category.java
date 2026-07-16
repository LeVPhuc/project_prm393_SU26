package com.vunven.backend.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "categories")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Category {
    @Id
    @Column(length = 50)
    private String id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(length = 50)
    private String icon;

    @Column(nullable = false, length = 20)
    private String type; // income, expense, both

    @Column(length = 20)
    private String color;

    @Builder.Default
    @Column(name = "is_system")
    private Boolean isSystem = true;
}
