package com.mergenc.maestro_ci_test

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.mergenc.maestro_ci_test.ui.theme.MaestrocitestTheme

@Composable
fun OnboardingScreen(
    email: String,
    modifier: Modifier = Modifier,
    onBack: () -> Unit
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.Center
    ) {
        Text("Onboarding Branch Test")
        Text(
            text = "Hos geldin $email",
            modifier = Modifier.padding(top = 8.dp)
        )
        Button(
            modifier = Modifier
                .padding(top = 16.dp)
                .fillMaxWidth()
                .height(48.dp),
            onClick = onBack
        ) {
            Text("Geri don")
        }
    }
}

@Preview(showBackground = true)
@Composable
fun OnboardingScreenPreview() {
    MaestrocitestTheme {
        OnboardingScreen(
            email = "test@mail.com",
            onBack = {}
        )
    }
}
