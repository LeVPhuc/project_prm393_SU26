package com.vunven.backend.repository;

import com.vunven.backend.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, String> {
    List<Notification> findByUserIdOrderByScheduledAtDesc(String userId);
}
