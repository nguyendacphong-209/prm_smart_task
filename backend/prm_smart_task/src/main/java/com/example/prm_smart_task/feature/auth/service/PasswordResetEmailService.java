package com.example.prm_smart_task.feature.auth.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class PasswordResetEmailService {

    private final JavaMailSender mailSender;
    private final String fromAddress;

    public PasswordResetEmailService(
            JavaMailSender mailSender,
            @Value("${app.mail.from:}") String fromAddress) {
        this.mailSender = mailSender;
        this.fromAddress = fromAddress;
    }

    public void sendResetCode(String recipient, String resetCode) {
        SimpleMailMessage message = new SimpleMailMessage();
        if (!fromAddress.isBlank()) {
            message.setFrom(fromAddress);
        }
        message.setTo(recipient);
        message.setSubject("PRM Smart Task password reset");
        message.setText("We received a request to reset your PRM Smart Task password.\n\n"
                + "Enter this code in the app to choose a new password:\n"
                + resetCode + "\n\n"
                + "This code expires in 30 minutes. If you did not request this, you can ignore this email.");
        mailSender.send(message);
    }
}
