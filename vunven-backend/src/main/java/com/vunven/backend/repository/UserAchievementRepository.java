package com.vunven.backend.repository;

import com.vunven.backend.entity.UserAchievement;
import com.vunven.backend.entity.UserAchievementId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface UserAchievementRepository extends JpaRepository<UserAchievement, UserAchievementId> {
    List<UserAchievement> findByUserId(String userId);
}
