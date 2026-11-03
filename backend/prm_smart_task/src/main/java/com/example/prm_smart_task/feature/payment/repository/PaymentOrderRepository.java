package com.example.prm_smart_task.feature.payment.repository;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import com.example.prm_smart_task.feature.payment.entity.PaymentOrder;

public interface PaymentOrderRepository extends JpaRepository<PaymentOrder, UUID> {
    Optional<PaymentOrder> findByOrderCode(long orderCode);
    Optional<PaymentOrder> findByIdAndUserEmail(UUID id, String email);
}
