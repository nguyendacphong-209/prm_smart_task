package com.smarttask.service;

import com.smarttask.dto.request.LoginRequest;
import com.smarttask.dto.request.RegisterRequest;
import com.smarttask.dto.response.AuthResponse;

public interface AuthService {
    AuthResponse register(RegisterRequest request);
    AuthResponse login(LoginRequest request);
}
