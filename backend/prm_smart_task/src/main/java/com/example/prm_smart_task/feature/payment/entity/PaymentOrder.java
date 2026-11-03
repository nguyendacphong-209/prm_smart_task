package com.example.prm_smart_task.feature.payment.entity;

import java.time.LocalDateTime;
import java.util.UUID;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UuidGenerator;
import com.example.prm_smart_task.feature.user.entity.AppUser;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "payment_orders")
@Getter
@Setter
public class PaymentOrder {
    @Id
    @GeneratedValue
    @UuidGenerator
    private UUID id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private AppUser user;
    @Column(name = "order_code", nullable = false, unique = true)
    private long orderCode;
    @Column(nullable = false)
    private long amount;
    @Column(name = "plan_code", nullable = false)
    private String planCode;
    @Column(nullable = false)
    private String status;
    @Column(name = "checkout_url", columnDefinition = "TEXT")
    private String checkoutUrl;
    @Column(name = "qr_code", columnDefinition = "TEXT")
    private String qrCode;
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    @Column(name = "paid_at")
    private LocalDateTime paidAt;
    @Column(name = "vip_expires_at")
    private LocalDateTime vipExpiresAt;
}
