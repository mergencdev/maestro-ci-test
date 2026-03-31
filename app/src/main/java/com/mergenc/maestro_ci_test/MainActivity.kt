package com.mergenc.maestro_ci_test

import android.os.Bundle
import android.util.Patterns
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.mergenc.maestro_ci_test.ui.theme.MaestrocitestTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MaestrocitestTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    SimpleFlow(modifier = Modifier.padding(innerPadding))
                }
            }
        }
    }
}

@Composable
fun SimpleFlow(modifier: Modifier = Modifier) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var currentScreen by remember { mutableStateOf("login") }
    var showInvalidEmailDialog by remember { mutableStateOf(false) }

    if (currentScreen == "onboarding") {
        OnboardingScreen(
            email = email,
            modifier = modifier,
            onBack = { currentScreen = "login" }
        )
        return
    }

    LoginScreen(
        email = email,
        password = password,
        showInvalidEmailDialog = showInvalidEmailDialog,
        modifier = modifier,
        onEmailChange = { email = it },
        onPasswordChange = { password = it },
        onDismissDialog = { showInvalidEmailDialog = false },
        onContinue = {
            if (Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
                currentScreen = "onboarding"
            } else {
                showInvalidEmailDialog = true
            }
        }
    )
}

@Preview(showBackground = true)
@Composable
fun SimpleFlowPreview() {
    MaestrocitestTheme {
        SimpleFlow()
    }
}