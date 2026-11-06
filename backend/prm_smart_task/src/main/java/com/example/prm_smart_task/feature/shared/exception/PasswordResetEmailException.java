package com.example.prm_smart_task.feature.shared.exception;

public class PasswordResetEmailException extends RuntimeException {

    public PasswordResetEmailException(String message) {
        super(message);
    }

    public PasswordResetEmailException(String message, Throwable cause) {
        super(message, cause);
    }
}
