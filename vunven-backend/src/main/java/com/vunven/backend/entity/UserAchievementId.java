package com.vunven.backend.entity;

import java.io.Serializable;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserAchievementId implements Serializable {
    private String user;
    private String achievement;
}
