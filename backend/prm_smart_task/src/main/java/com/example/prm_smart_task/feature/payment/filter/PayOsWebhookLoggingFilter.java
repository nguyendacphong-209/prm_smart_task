package com.example.prm_smart_task.feature.payment.filter;

import java.io.IOException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class PayOsWebhookLoggingFilter extends OncePerRequestFilter {
    private static final String WEBHOOK_PATH = "/api/payments/payos/webhook";
    private static final Logger logger = LoggerFactory.getLogger(PayOsWebhookLoggingFilter.class);

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !WEBHOOK_PATH.equals(request.getServletPath());
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        logger.info("PayOS webhook request received: method={}, contentType={}, contentLength={}",
                request.getMethod(), request.getContentType(), request.getContentLengthLong());
        try {
            filterChain.doFilter(request, response);
        } finally {
            logger.info("PayOS webhook request completed: method={}, status={}",
                    request.getMethod(), response.getStatus());
        }
    }
}
